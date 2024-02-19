# frozen_string_literal: true

require "rails_helper"
require "support/devise_helpers"

RSpec.describe "User signs up" do
  include DeviseHelpers

  it "with valid data" do
    visit new_user_registration_path

    fill_in_email "username@example.com"
    fill_in_password "password123456"
    fill_in_password_confirmation "password123456"
    click_on I18n.t("simple_form.labels.user.submit_registration")

    expect(page).to have_text I18n.t("devise.registrations.signed_up")
    expect(page).to have_current_path root_path
  end

  it "with invalid data" do
    visit new_user_registration_path

    click_on I18n.t("simple_form.labels.user.submit_registration")

    expect(page).to have_text I18n.t("errors.messages.blank", attribute: "E-post")
    expect(page).to have_text I18n.t("errors.messages.blank", attribute: "Passord")
  end
end
