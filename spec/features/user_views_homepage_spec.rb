# frozen_string_literal: true

require "rails_helper"

describe "User views homepage", :js do
  let!(:space_one) do
    Fabricate(:space, address: "Ulefossvegen 32", post_number: 3730, post_address: "Skien", lat: 59.196, lng: 9.603,
                      space_types: [Fabricate(:space_type, type_name: "Space one type")])
  end
  let!(:space_two) do
    Fabricate(:space, address: "Ulefossvegen 16", post_number: 3730, post_address: "Skien", lat: 59.196, lng: 9.607,
                      space_types: [Fabricate(:space_type, type_name: "Space two type")])
  end
  let!(:facility_toilet) { Fabricate(:facility, title: "Toilet") }
  let!(:facility_beds) { Fabricate(:facility, title: "Beds") }

  before do
    create_user!
    login_with_warden!

    category = Fabricate(:facility_category)
    category.facilities << facility_toilet
    category.facilities << facility_beds

    Fabricate(:facility_review, space: space_one, facility: facility_toilet, experience: :was_allowed)
    Fabricate(:facility_review, space: space_one, facility: facility_beds, experience: :was_not_allowed)

    Fabricate(:facility_review, space: space_two, facility: facility_toilet, experience: :was_not_allowed)
    Fabricate(:facility_review, space: space_two, facility: facility_beds, experience: :was_allowed)

    space_one.aggregate_facility_reviews
    space_two.aggregate_facility_reviews
  end

  it "User can filter spaces, and get them in the correct order" do
    login_and_logout_with_warden do
      visit root_path

      expect(page).to have_content(space_one.title)
      expect(page).to have_content(space_two.title)

      click_on("toggle_search_box")
      check(facility_toilet.title)

      # We must wait because find will find the element but it may not be in correct order yet..
      sleep(0.3)

      expect(find_by_id("space-listing").first("h3").text).to eq(space_one.title)

      uncheck(facility_toilet.title)
      check(facility_beds.title)

      # We must wait because find will find the element but it may not be in correct order yet..
      sleep(0.3)

      expect(find_by_id("space-listing").first("h3").text).to eq(space_two.title)

      uncheck(facility_toilet.title)
      uncheck(facility_beds.title)

      check(space_one.space_types.first.type_name)

      expect(page).to have_no_content(space_two.title)

      uncheck(space_one.space_types.first.type_name)

      check(space_two.space_types.first.type_name)

      expect(page).to have_no_content(space_one.title)
    end
  end
end
