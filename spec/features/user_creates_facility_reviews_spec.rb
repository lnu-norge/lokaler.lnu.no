# frozen_string_literal: true

require "rails_helper"
require "support/user_creates_facility_reviews_helpers"

describe "User creates facility reviews for", :js do
  include UserCreatesFacilityReviewsHelpers

  let!(:space) do
    Fabricate(:space, address: "Ulefossvegen 32", post_number: 3730, post_address: "Skien", lat: 59.196, lng: 9.603)
  end

  let!(:facility_to_review) { space.relevant_space_facilities.first.facility }
  let!(:second_facility_to_review) { space.relevant_space_facilities.second.facility }

  around do |test|
    create_user!

    login_and_logout_with_warden do
      test.run
    end
  end

  it "a single facility, with no description" do
    visit space_path(space)

    expect_to_add_facility_review(
      space:,
      facility: facility_to_review
    )
  end

  it "a single facility, with a description" do
    visit space_path(space)

    expect_to_add_facility_review(
      space:,
      facility: facility_to_review,
      description_to_add: Faker::Lorem.sentence
    )
  end

  it "two facilities, at the same time" do
    visit space_path(space)

    expect_to_add_multiple_facility_reviews(
      space:,
      facilities_to_review: [facility_to_review, second_facility_to_review]
    )
  end

  it "two facilities, one at a time, and checks that changes are only made to the reviewed facilities" do
    visit space_path(space)

    expect_to_add_facility_review(
      space:,
      facility: facility_to_review
    )

    expect_to_add_facility_review(
      count_that_already_have_the_new_experience: 1,
      space:,
      facility: second_facility_to_review
    )
  end

  it "a single facility twice, adding a description the second time" do
    visit space_path(space)

    expect_to_add_facility_review(
      space:,
      facility: facility_to_review
    )

    expect_to_only_change_facility_review_description(
      space:,
      facility: facility_to_review,
      description_to_add: Faker::Lorem.sentence
    )
  end
end
