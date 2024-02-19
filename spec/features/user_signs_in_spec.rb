# frozen_string_literal: true

require "rails_helper"
require "support/devise_helpers"

RSpec.describe "User signs in" do
  include DeviseHelpers

  it "with valid credentials" do
    user = Fabricate :user

    visit new_user_session_path

    within ".new_user" do
      fill_in_email user.email
      fill_in_password user.password
      click_login_button
    end

    expect(page).to have_text I18n.t("simple_form.labels.user.signed_in")
    expect(page).to have_current_path root_path
  end

  it "with invalid credentials" do
    user = Fabricate.build :user

    visit new_user_session_path

    within ".new_user" do
      fill_in_email user.email
      fill_in_password "wrong_password"
      click_login_button
    end

    expect(page).to have_text I18n.t("devise.failure.invalid", authentication_keys: "E-post")
  end
end
