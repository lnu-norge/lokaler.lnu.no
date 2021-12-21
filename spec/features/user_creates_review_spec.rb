# frozen_string_literal: true

require "rails_helper"

describe "User creates review", js: true do
  let!(:space) do
    Fabricate(:space, address: "Ulefossvegen 32", post_number: 3730, post_address: "Skien", lat: 59.196, lng: 9.603)
  end

  let!(:facility1) do
    Fabricate(:facility)
  end
  let!(:facility2) do
    Fabricate(:facility)
  end

  before do
    create_user!

    facility1
    facility2
    space.aggregate_facility_reviews
  end

  it "User creates a full review" do
    login_and_logout_with_warden do
      visit space_path(space)

      first(:link, I18n.t("reviews.add_review")).click
      click_link(I18n.t("reviews.form.have_you_been_there_answers.been_there"))

      choose("review_facility_reviews_attributes_#{facility1.id}__experience_was_not_available",
             allow_label_click: true)
      choose("review_facility_reviews_attributes_#{facility2.id}__experience_was_allowed", allow_label_click: true)
      find("span", text: I18n.t("multistep_form_navigation.next")).click

      choose("review_star_rating_1", allow_label_click: true)

      fill_in("review_title", with: "Review Title!")
      fill_in("review_comment", with: "Review Comment!")

      find("span", text: I18n.t("multistep_form_navigation.next")).click

      choose("review_how_much_one_room", allow_label_click: true)
      choose("review_how_long_one_evening", allow_label_click: true)
      choose("review_payment_yes", allow_label_click: true)
      fill_in("review_price", with: "5000")

      click_button(I18n.t("multistep_form_navigation.save"))

      expect(page).to have_content("Review Title!")
      expect(page).to have_content("Review Comment!")
      expect(page).to have_content(facility1.title)
      expect(page).to have_content(facility2.title)
      expect(page).to have_content("5000 kr")
    end
  end

  it "User creates a not allowed review" do
    login_and_logout_with_warden do
      visit space_path(space)

      first(:link, I18n.t("reviews.add_review")).click
      click_link(I18n.t("reviews.form.have_you_been_there_answers.not_allowed_to_use"))

      fill_in("review_title", with: "Review Title!")
      fill_in("review_comment", with: "Review Comment!")

      find("span", text: I18n.t("multistep_form_navigation.next")).click

      choose("review_facility_reviews_attributes_#{facility1.id}__experience_was_not_available",
             allow_label_click: true)
      choose("review_facility_reviews_attributes_#{facility2.id}__experience_was_allowed",
             allow_label_click: true)

      click_button(I18n.t("multistep_form_navigation.save"))
      expect(page).to have_content(I18n.t("activerecord.attributes.review.not_allowed_to_use"))

      expect(page).to have_content("Review Title!")
      expect(page).to have_content("Review Comment!")
      expect(page).to have_content(facility1.title)
      expect(page).to have_content(facility2.title)
    end
  end

  it "User creates a only contacted review" do
    login_and_logout_with_warden do
      visit space_path(space)

      first(:link, I18n.t("reviews.add_review")).click
      click_link(I18n.t("reviews.form.have_you_been_there_answers.only_contacted"))

      choose("review_facility_reviews_attributes_#{facility1.id}__experience_was_not_available",
             allow_label_click: true)

      choose("review_facility_reviews_attributes_#{facility2.id}__experience_was_allowed",
             allow_label_click: true)

      click_button(I18n.t("multistep_form_navigation.save"))

      expect(page).to have_content(I18n.t("activerecord.attributes.review.only_contacted"))
      expect(page).to have_content(facility1.title)
      expect(page).to have_content(facility2.title)
    end
  end
end
