# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::OmniauthCallbacksController", type: :request do
  before do
    # Configure OmniAuth test mode
    OmniAuth.config.test_mode = true
  end

  after do
    # Clean up OmniAuth test mode
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  describe "POST /users/auth/google_oauth2/callback" do
    let(:email) { "test@example.com" }
    let(:first_name) { "John" }
    let(:last_name) { "Doe" }

    let(:google_auth_hash) do
      OmniAuth::AuthHash.new({
                               provider: "google_oauth2",
                               uid: "123456789",
                               info: {
                                 email: email,
                                 first_name: first_name,
                                 last_name: last_name,
                                 name: "#{first_name} #{last_name}"
                               },
                               credentials: {
                                 token: "token",
                                 refresh_token: "refresh_token",
                                 expires_at: 1.week.from_now
                               }
                             })
    end

    before do
      # Mock the OmniAuth auth hash
      OmniAuth.config.mock_auth[:google_oauth2] = google_auth_hash
    end

    context "when user does not exist" do
      it "creates a new user and signs them in" do
        expect do
          post "/auth/google_oauth2/callback"
        end.to change(User, :count).by(1)

        user = User.last
        expect(user.email).to eq(email)
        expect(user.first_name).to eq(first_name)
        expect(user.last_name).to eq(last_name)

        # User is redirected to complete missing information (organization)
        expect(response).to redirect_to(edit_user_registration_path)
        follow_redirect!
        expect(controller.current_user).to eq(user)
      end
    end

    context "when user already exists" do
      let!(:existing_user) do
        Fabricate(:user, email: email, first_name: "Jane", last_name: "Smith", in_organization: false)
      end

      it "signs in the existing user without creating a new one" do
        expect do
          post "/auth/google_oauth2/callback"
        end.not_to change(User, :count)

        # User has complete information so goes to root
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(controller.current_user).to eq(existing_user)
      end

      it "does not update existing user's name (User.from_google only sets on creation)" do
        post "/auth/google_oauth2/callback"

        existing_user.reload
        # User.from_google uses create_with which only applies on creation, not updates
        expect(existing_user.first_name).to eq("Jane")
        expect(existing_user.last_name).to eq("Smith")
      end
    end

    context "when Google auth fails" do
      before do
        OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
      end

      it "redirects to sign in with error message" do
        post "/auth/google_oauth2/callback"

        expect(response).to redirect_to(new_user_session_path)
        follow_redirect!
        expect(flash[:alert]).to be_present
      end
    end

    context "with cross-authentication method compatibility" do
      context "when user was created via magic link" do
        let!(:magic_link_user) do
          Fabricate(:user, email: email, first_name: "Magic", last_name: "User", in_organization: false)
        end

        it "signs in the same user that was created via magic link" do
          expect do
            post "/auth/google_oauth2/callback"
          end.not_to change(User, :count)

          # User has complete information so goes to root
          expect(response).to redirect_to(root_path)
          follow_redirect!
          expect(controller.current_user).to eq(magic_link_user)
        end

        it "does not update the magic link user's name (User.from_google only sets on creation)" do
          post "/auth/google_oauth2/callback"

          magic_link_user.reload
          # User.from_google uses create_with which only applies on creation, not updates
          expect(magic_link_user.first_name).to eq("Magic")
          expect(magic_link_user.last_name).to eq("User")
          expect(magic_link_user.email).to eq(email)
        end
      end

      context "when user signs in with magic link after Google OAuth" do
        let!(:google_user) { Fabricate(:user, email: email, first_name: first_name, last_name: last_name) }

        it "finds the same user when using magic link authentication" do
          # Simulate finding user for magic link (this is what User.from_google does)
          found_user = User.find_or_create_by(email: email) do |user|
            user.first_name = "Different"
            user.last_name = "Name"
          end

          expect(found_user).to eq(google_user)
          expect(found_user.first_name).to eq(first_name) # Should keep existing data
          expect(found_user.last_name).to eq(last_name)
        end
      end
    end

    context "when user remembers session" do
      it "sets remember_me cookie" do
        post "/auth/google_oauth2/callback"

        expect(response.cookies["remember_user_token"]).to be_present
      end
    end

    context "when user has missing information" do
      let(:first_name) { nil }

      it "still creates and signs in the user" do
        expect do
          post "/auth/google_oauth2/callback"
        end.to change(User, :count).by(1)

        user = User.last
        expect(user.email).to eq(email)
        expect(user.first_name).to be_nil
        expect(user.last_name).to eq(last_name)

        # User is redirected to complete missing information (organization)
        expect(response).to redirect_to(edit_user_registration_path)
      end
    end
  end
end
