# frozen_string_literal: true

require "rails_helper"
require "support/devise_helpers"

RSpec.describe "User signs out" do
  include DeviseHelpers

  it "user signed in" do
    user = Fabricate :user

    sign_in user

    visit edit_session_path

    click_on I18n.t("simple_form.labels.user.signout")

    expect(page).to have_text I18n.t("simple_form.labels.user.signed_out")
    expect(page).to have_current_path root_path
  end
end
