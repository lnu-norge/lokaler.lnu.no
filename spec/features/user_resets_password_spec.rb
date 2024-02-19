# frozen_string_literal: true

require "rails_helper"
require "support/devise_helpers"

RSpec.describe "User resets a password" do
  include DeviseHelpers

  it "user enters a valid email" do
    user = Fabricate :user

    visit new_user_password_path

    fill_in_email user.email

    expect do
      click_reset_password_button
    end.to change { ActionMailer::Base.deliveries.size }.by(1)

    expect(page).to have_text I18n.t("devise.passwords.send_instructions")
    expect(page).to have_current_path new_user_session_path
  end

  it "user enters an invalid email" do
    visit new_user_password_path

    fill_in_email "no_such_email@example.com"
    click_reset_password_button

    # Translation of Email not found
    expect(page).to have_text I18n.t("errors.messages.not_found", attribute: "Email")
  end

  it "user changes password" do
    token = Fabricate(:user).send_reset_password_instructions

    visit edit_user_password_path(reset_password_token: token)

    fill_in_and_ask_for_new_password

    expect(page).to have_text I18n.t("devise.passwords.updated")
    expect(page).to have_current_path root_path
  end

  it "password reset token is invalid" do
    visit edit_user_password_path(reset_password_token: "fake_token")

    fill_in_and_ask_for_new_password

    expect(page).to have_no_text I18n.t("devise.passwords.updated")
    expect(page).to have_no_current_path root_path
  end
end
