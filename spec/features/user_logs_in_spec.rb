# frozen_string_literal: true

require "rails_helper"

describe "User logs in", :js do
  before { Fabricate(:user, email: "test@example.net", password: "secret", password_confirmation: "secret") }

  it "user logs in successfully" do
    visit new_user_session_path
    fill_in "user_email", with: "test@example.net"
    fill_in "user_password", with: "secret"
    click_button I18n.t("simple_form.labels.user.session.login_with_email")

    expect(page).to have_current_path(root_path, ignore_query: true)
    expect(page).to have_content(I18n.t("menu.new_space"))
  end

  it "unsuccessful login" do
    visit new_user_session_path
    fill_in "user_email", with: "test@example.net"
    fill_in "user_password", with: "wrong"
    click_button I18n.t("simple_form.labels.user.session.login_with_email")

    expect(page).to have_current_path(new_user_session_path, ignore_query: true)
    expect(page).to have_content(I18n.t("simple_form.labels.user.session.heading_new"))
  end
end
