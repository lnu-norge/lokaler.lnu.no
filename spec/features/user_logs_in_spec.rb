# frozen_string_literal: true

require "rails_helper"

describe User, js: true do
  before { Fabricate(:user, email: "test@example.net", password: "secret", password_confirmation: "secret") }

  it "user logs in successfully" do
    visit root_path
    fill_in "user_email", with: "test@example.net"
    fill_in "user_password", with: "secret"
    click_button "Logg in"

    expect(page).to have_current_path(root_path, ignore_query: true)
    expect(page).to have_content("Nytt lokale")
  end

  it "unsuccessful login" do
    visit root_path
    fill_in "user_email", with: "test@example.net"
    fill_in "user_password", with: "wrong"
    click_button "Logg in"

    expect(page).to have_current_path(root_path, ignore_query: true)
    expect(page).to have_content("Logg inn til din bruker")
  end
end
