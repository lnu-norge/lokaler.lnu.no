# frozen_string_literal: true

require "rails_helper"

describe "User creates review", :js do
  let!(:space) do
    Fabricate(:space, address: "Ulefossvegen 32", post_number: 3730, post_address: "Skien", lat: 59.196, lng: 9.603)
  end

  before do
    create_user!

    space.aggregate_facility_reviews
  end

  it "User creates a full review" do
    login_and_logout_with_warden do
      visit space_path(space)

      click_on(I18n.t("reviews.add_review"))

      choose("review_star_rating_1", allow_label_click: true)

      fill_in("review_comment", with: "Review Comment!")

      click_on(I18n.t("multistep_form_navigation.save"))

      expect(page).to have_content("Review Comment!")
    end
  end
end
