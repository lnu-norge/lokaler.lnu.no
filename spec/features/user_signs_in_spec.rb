# frozen_string_literal: true

require "rails_helper"
require "support/devise_helpers"

RSpec.describe "User signs in" do
  include DeviseHelpers

  it "sends a magic link" do
    user = Fabricate :user

    visit new_user_session_path
    within ".new_user" do
      fill_in_email user.email
      click_on "Send kode"
    end

    expect(page).to have_text I18n.t("devise.passwordless.magic_link_sent", email: user.email)

    # Expect an email with a magic link inside to be sent
    email = ActionMailer::Base.deliveries.last
    expect(email.subject).to eq I18n.t("devise.mailer.magic_link.subject")
    expect(email.to).to eq [user.email]

    # Extract the magic link from the HTML part of the email
    html_part = email.parts.find { |part| part.content_type.include?("text/html") }
    html_body = html_part.body.decoded

    # Use a regex to extract the link
    magic_link_from_html = html_body.match(/href="(.+)"/)[1]
    # Replace &amp; with &
    magic_link_from_html.gsub!("&amp;", "&")

    # Visit the sign-in link
    visit magic_link_from_html

    # Expect the user to be logged in
    expect(page).to have_text I18n.t("devise.sessions.user.signed_in")
  end
end
