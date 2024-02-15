# frozen_string_literal: true

require "rails_helper"

describe "User creates facility reviews", :js do
  let!(:space) do
    Fabricate(:space, address: "Ulefossvegen 32", post_number: 3730, post_address: "Skien", lat: 59.196, lng: 9.603)
  end

  before do
    create_user!
  end

  it "User leaves facility reviews for both facilities" do
    no_reviews_selector = "li[title='#{I18n.t('tooltips.facility_aggregated_experience.unknown')}']"
    reviewed_selector = "li[title='#{I18n.t('tooltips.facility_aggregated_experience.likely')}']"

    first_facility = space.space_facilities.first.facility
    second_facility = space.space_facilities.second.facility

    login_and_logout_with_warden do
      visit space_path(space)

      expect(page).to have_selector(no_reviews_selector)

      find("button[aria-label='Rediger fasiliteter']").click

      fieldset = find("fieldset", text: first_facility.title)
      within(fieldset) do
        click_on("Rediger")
        choose(I18n.t("reviews.form.facility_experience_particular_tense.was_allowed"), allow_label_click: true)
      end

      second_fieldset = find("fieldset", text: second_facility.title)
      within(second_fieldset) do
        click_on("Rediger")
        choose(I18n.t("reviews.form.facility_experience_particular_tense.was_allowed"), allow_label_click: true)
      end

      click_on(I18n.t("facility_reviews.save"))

      expect(page).to have_selector(reviewed_selector)
      expect(page).to have_no_selector(no_reviews_selector)
    end
  end
end
