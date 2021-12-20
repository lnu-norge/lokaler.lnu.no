# frozen_string_literal: true

require "rails_helper"

describe "User views homepage", js: true do
  let!(:space1) do
    Fabricate(:space, address: "Ulefossvegen 32", post_number: 3730, post_address: "Skien", lat: 59.196, lng: 9.603)
  end
  let!(:space2) do
    Fabricate(:space, address: "Ulefossvegen 16", post_number: 3730, post_address: "Skien", lat: 59.196, lng: 9.607)
  end
  let!(:facility1) { Fabricate(:facility) }
  let!(:facility2) { Fabricate(:facility) }

  before do
    create_user!

    review1 = Fabricate(:review, space: space1)
    review2 = Fabricate(:review, space: space2)

    Fabricate(:facility_review, review: review1, space: space1, facility: facility1, experience: :was_allowed)
    Fabricate(:facility_review, review: review1, space: space1, facility: facility2, experience: :was_not_allowed)

    Fabricate(:facility_review, review: review2, space: space2, facility: facility1, experience: :was_not_allowed)
    Fabricate(:facility_review, review: review2, space: space2, facility: facility2, experience: :was_allowed)

    space1.aggregate_facility_reviews
    space2.aggregate_facility_reviews
  end

  it "User can see both spaces" do
    login_and_logout_with_warden do
      visit root_path

      expect(page).to have_content(space1.title)
      expect(page).to have_content(space2.title)
    end
  end

  RSpec::Matchers.define :appear_before do |later_content|
    match do |earlier_content|
      retries = 0
      # We have to retry until the page is loaded
      # should probably be a timeout instead of just retrying 5 times
      retries += 1 while retries < 5 && (page.body.index(earlier_content).nil? || page.body.index(later_content).nil?)
      page.body.index(earlier_content) < page.body.index(later_content)
    end
  end

  it "User can see space1 before space2" do
    login_and_logout_with_warden do
      visit root_path

      click_button("toggle_search_box")
      check(facility1.title)

      expect(space1.title).to appear_before(space2.title)
    end
  end

  it "User can see space2 before space1" do
    login_and_logout_with_warden do
      visit root_path

      click_button("toggle_search_box")
      check(facility2.title)

      expect(space2.title).to appear_before(space1.title)
    end
  end

  it "User can see only see space1" do
    login_and_logout_with_warden do
      visit root_path

      click_button("toggle_search_box")
      check(space1.space_type.type_name)

      expect(page).not_to have_content(space2.title)
    end
  end

  it "User can see only see space2" do
    login_and_logout_with_warden do
      visit root_path

      click_button("toggle_search_box")
      check(space2.space_type.type_name)

      expect(page).not_to have_content(space1.title)
    end
  end
end
