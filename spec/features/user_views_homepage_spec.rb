# frozen_string_literal: true

require "rails_helper"

describe "User views homepage", js: true do
  let!(:space1) do
    Fabricate(:space, address: "Ulefossvegen 32", post_number: 3730, post_address: "Skien", lat: 59.196, lng: 9.603,
                      space_types: [Fabricate(:space_type, type_name: "Type1")])
  end
  let!(:space2) do
    Fabricate(:space, address: "Ulefossvegen 16", post_number: 3730, post_address: "Skien", lat: 59.196, lng: 9.607,
                      space_types: [Fabricate(:space_type, type_name: "Type2")])
  end
  let!(:facility1) { Fabricate(:facility, title: "Facility1") }
  let!(:facility2) { Fabricate(:facility, title: "Facility2") }

  before do
    create_user!
    login_with_warden!

    category = Fabricate(:facility_category)
    category.facilities << facility1
    category.facilities << facility2

    Fabricate(:facility_review, space: space1, facility: facility1, experience: :was_allowed)
    Fabricate(:facility_review, space: space1, facility: facility2, experience: :was_not_allowed)
    Fabricate(:facility_review, space: space2, facility: facility1, experience: :was_not_allowed)
    Fabricate(:facility_review, space: space2, facility: facility2, experience: :was_allowed)

    space1.aggregate_facility_reviews
    space2.aggregate_facility_reviews
  end

  it "User can see space1 before space2" do
    login_and_logout_with_warden do
      visit root_path

      expect(page).to have_content(space1.title)
      expect(page).to have_content(space2.title)

      click_button("toggle_search_box")
      check(facility1.title)

      # We must wait because find will find the element but it may not be in correct order yet..
      sleep(0.2)

      expect(find("#space-listing").first("h3").text).to eq(space1.title)

      uncheck(facility1.title)
      check(facility2.title)

      # We must wait because find will find the element but it may not be in correct order yet..
      sleep(0.2)

      expect(find("#space-listing").first("h3").text).to eq(space2.title)

      uncheck(facility1.title)
      uncheck(facility2.title)

      check(space1.space_types.first.type_name)

      expect(page).not_to have_content(space2.title)

      uncheck(space1.space_types.first.type_name)

      check(space2.space_types.first.type_name)

      expect(page).not_to have_content(space1.title)
    end
  end
end
