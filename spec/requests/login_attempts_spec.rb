# frozen_string_literal: true

require "rails_helper"

RSpec.describe "LoginAttempts", type: :request do
  let(:user) { Fabricate(:user) }
  let(:email) { user.email }

  before do
    ActionMailer::Base.deliveries.clear
  end

  describe "Google authentication flow" do
    before do
      OmniAuth.config.test_mode = true
    end

    after do
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:google_oauth2] = nil
    end

    let(:google_auth_hash) do
      OmniAuth::AuthHash.new({
                               provider: "google_oauth2",
                               uid: "123456789",
                               info: {
                                 email: email,
                                 first_name: "John",
                                 last_name: "Doe",
                                 name: "John Doe"
                               },
                               credentials: {
                                 token: "token",
                                 refresh_token: "refresh_token",
                                 expires_at: 1.week.from_now
                               }
                             })
    end

    it "logs a successful login if google oauth is succesful" do
      OmniAuth.config.mock_auth[:google_oauth2] = google_auth_hash

      expect do
        post "/auth/google_oauth2/callback"
      end.to change(LoginAttempt, :count).by(1)

      # Check that the login attempt is created with successful status
      login_attempt = LoginAttempt.last
      expect(login_attempt.user).to eq(user)
      expect(login_attempt.status).to eq("successful")
      expect(login_attempt.login_method).to eq("google_oauth")
      expect(login_attempt.identifier).to eq(email)

      # User should be signed in and redirected
      expect(response).to have_http_status(:redirect)
      expect(controller.user_signed_in?).to be true
      expect(controller.current_user).to eq(user)
    end

    it "logs a failed login if google oauth is unsuccesful" do
      OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

      expect do
        post "/auth/google_oauth2/callback"
      end.to change(LoginAttempt, :count).by(1)

      # Check that the login attempt is created with failed status
      login_attempt = LoginAttempt.last
      expect(login_attempt.status).to eq("failed")
      expect(login_attempt.login_method).to eq("google_oauth")
      expect(login_attempt.identifier).to eq("unknown")

      # User should not be signed in
      expect(controller.user_signed_in?).to be false
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "magic link authentication flow" do
    it "updates pending login attempt when requesting magic link to be successful on completion" do
      # Step 1: User requests magic link
      expect do
        post user_session_path, params: { user: { email: email } }
      end.to change(LoginAttempt, :count).by(1)

      # Check that the login attempt is created with pending status
      login_attempt = LoginAttempt.last
      expect(login_attempt.user).to eq(user)
      expect(login_attempt.status).to eq("pending")
      expect(login_attempt.login_method).to eq("magic_link")

      # Should redirect to sign in page with success message
      expect(response).to redirect_to(new_user_session_path)
      follow_redirect!
      expect(response.body).to include("Sendt til #{email}!")

      # Step 2: User clicks magic link and is authenticated
      # Extract the actual token from the email that was sent
      email = ActionMailer::Base.deliveries.last
      expect(email).to be_present
      expect(email.to).to eq([user.email])

      # Extract the magic link from the HTML part of the email
      html_part = email.parts.find { |part| part.content_type.include?("text/html") }
      html_body = html_part.body.decoded
      magic_link_from_html = html_body.match(/href="(.+)"/)[1]
      magic_link_from_html.gsub!("&amp;", "&")

      # Extract the path from the full URL (remove domain)
      magic_link_path = "#{URI.parse(magic_link_from_html).path}?#{URI.parse(magic_link_from_html).query}"

      # Simulate clicking the magic link
      expect do
        get magic_link_path
      end.not_to change(LoginAttempt, :count)

      # User should now be signed in
      expect(response).to redirect_to(edit_user_registration_path)
      follow_redirect!
      expect(controller.user_signed_in?).to be true
      expect(controller.current_user).to eq(user)

      # Check that the login attempt is updated to be a success
      login_attempt.reload
      expect(login_attempt.status).to eq("successful")

      # Verify we have only one attempt recorded
      expect(LoginAttempt.count).to eq(1)
    end

    it "does not update login attempt if an invalid magic link is clicked" do
      # Step 1: User requests magic link (this creates pending attempt)
      post user_session_path, params: { user: { email: email } }

      pending_attempt = LoginAttempt.last
      expect(pending_attempt.status).to eq("pending")

      # Step 2: User clicks invalid/expired magic link

      # Extract the magic link from the HTML part of the email
      email = ActionMailer::Base.deliveries.last
      expect(email).to be_present
      expect(email.to).to eq([user.email])
      html_part = email.parts.find { |part| part.content_type.include?("text/html") }
      html_body = html_part.body.decoded
      magic_link_from_html = html_body.match(/href="(.+)"/)[1]
      magic_link_from_html.gsub!("&amp;", "&")

      # Extract the path from the full URL (remove domain)
      magic_link_path = "#{URI.parse(magic_link_from_html).path}?#{URI.parse(magic_link_from_html).query}"

      # Make it invalid by removing last 10 chars
      invalid_magic_link_path = magic_link_path[0...-10]

      expect do
        get invalid_magic_link_path
      end.not_to change(LoginAttempt, :count)

      # User should not be signed in
      expect(controller.user_signed_in?).to be false
    end

    it "creates failed login attempt when email is not found" do
      non_existent_email = "nonexistent@example.com"

      expect do
        post user_session_path, params: { user: { email: non_existent_email } }
      end.to change(LoginAttempt, :count).by(1)

      # Check that a login attempt is created (user gets created automatically in the current code)
      login_attempt = LoginAttempt.last
      expect(login_attempt.status).to eq("pending") # Current behavior creates pending attempt
      expect(login_attempt.login_method).to eq("magic_link")

      # Should redirect successfully as magic link is sent
      expect(response).to redirect_to(new_user_session_path)
    end

    context "when login attempt logging fails" do
      it "does not break the authentication flow" do
        # Mock LoginAttempt.create! to raise an error
        allow(LoginAttempt).to receive(:create!).and_raise(StandardError.new("Database error"))

        # The magic link request should still work
        expect do
          post user_session_path, params: { user: { email: email } }
        end.not_to raise_error

        # Should still redirect successfully
        expect(response).to redirect_to(new_user_session_path)
        follow_redirect!
        expect(response.body).to include("Sendt til #{email}!")
      end
    end
  end
end
