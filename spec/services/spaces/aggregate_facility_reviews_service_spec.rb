# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spaces::AggregateFacilityReviewsService do
  let(:space_type) { Fabricate(:space_type) }
  let(:space) { Fabricate(:space, space_types: [space_type]) }
  let(:facility_category) { Fabricate(:facility_category) }
  let(:facility) { Fabricate(:facility, facility_categories: [facility_category], space_types: [space_type]) }

  def experience(experience, other_facility = nil)
    Fabricate(:facility_review, space:, experience:, facility: other_facility || facility)
    space.reload.aggregate_facility_reviews
  end

  it "turns into a relevant maybe if there are mixed reviews" do
    experience :was_allowed
    experience :was_not_allowed
    expect(space.reload.reviews_for_facility(facility)).to eq("maybe")
    expect(space.reload.relevance_of_facility(facility)).to be(true)
  end

  it "turns into a relevant likely if there are over 2/3 positive reviews" do
    experience :was_not_allowed
    3.times { experience :was_allowed }
    expect(space.reload.reviews_for_facility(facility)).to eq("likely")
    expect(space.reload.relevance_of_facility(facility)).to be(true)
  end

  it "turns into likely if there are over 2/3 positive reviews, even if those are only the last five" do
    10.times { experience :was_not_allowed }
    4.times { experience :was_allowed }
    expect(space.reload.reviews_for_facility(facility)).to eq("likely")
    expect(space.reload.relevance_of_facility(facility)).to be(true)
  end

  it "turns into impossible if half or more say it does not exist" do
    experience :was_not_allowed
    experience :was_not_available
    experience :was_not_available
    expect(space.reload.reviews_for_facility(facility)).to eq("impossible")
  end

  it "turns into unlikely if there are over 2/3 negative reviews" do
    experience :was_allowed
    2.times { experience :was_not_allowed }
    expect(space.reload.reviews_for_facility(facility)).to eq("unlikely")
  end

  it "Is unknown if no reviews, and turns back into unknown if all facility reviews are deleted" do
    facility # ensure that the facility object is made
    space.facility_reviews.destroy_all
    expect(space.reload.space_facilities.first.experience).to eq("unknown")

    2.times { experience :was_not_allowed }
    space.facility_reviews.destroy_all

    space.aggregate_facility_reviews

    expect(space.reload.reviews_for_facility(facility)).to eq("unknown")
  end

  it "Works even if there are unrelated facilities and reviews" do
    experience :was_allowed
    experience :was_not_allowed
    2.times do
      experience :was_allowed, Fabricate(:facility)
    end
    expect(space.reload.reviews_for_facility(facility)).to eq("maybe")
    expect(space.reload.relevance_of_facility(facility)).to be(true)
  end

  it "Is set as relevant if in space_type, even if impossible or negative or unknown" do
    experience :was_not_available
    expect(space.reload.relevance_of_facility(facility)).to be(true)

    space.facility_reviews.destroy_all
    space.aggregate_facility_reviews

    experience :was_not_allowed
    expect(space.reload.relevance_of_facility(facility)).to be(true)

    space.facility_reviews.destroy_all
    space.aggregate_facility_reviews

    expect(space.reload.relevance_of_facility(facility)).to be(true)
  end

  it "is set as irrelevant if negative or impossible and not in space_type" do
    non_space_type_facility = Fabricate(:facility, space_types: [Fabricate(:space_type)])

    experience :was_not_available, non_space_type_facility
    expect(space.reload.relevance_of_facility(non_space_type_facility)).to be(false)

    space.facility_reviews.destroy_all
    space.aggregate_facility_reviews

    experience :was_not_allowed, non_space_type_facility
    expect(space.reload.relevance_of_facility(non_space_type_facility)).to be(false)

    space.facility_reviews.destroy_all
    space.aggregate_facility_reviews

    expect(space.reload.relevance_of_facility(non_space_type_facility)).to be(false)
  end

  it "is set as relevant if a positive or maybe, even if it's not in the space type" do
    non_space_type_facility = Fabricate(:facility, space_types: [Fabricate(:space_type)])

    experience :was_allowed, non_space_type_facility

    expect(space.reload.reviews_for_facility(non_space_type_facility)).to eq("likely")
    expect(space.reload.relevance_of_facility(non_space_type_facility)).to be(true)

    experience :was_not_allowed, non_space_type_facility

    expect(space.reload.reviews_for_facility(non_space_type_facility)).to eq("maybe")
    expect(space.reload.relevance_of_facility(non_space_type_facility)).to be(true)
  end

  it "sets relevance if a facility is added to a Spaces space type" do
    other_facility = Fabricate(:facility, space_types: [Fabricate(:space_type)])

    expect(space.reload.relevance_of_facility(other_facility)).to be(false)

    other_facility.update!(space_types: [space_type])

    expect(space.reload.relevance_of_facility(other_facility)).to be(true)
  end

  it "removes relevance if a facility is removed from a Spaces space type" do
    other_facility = Fabricate(:facility, space_types: [space_type])

    expect(space.reload.relevance_of_facility(other_facility)).to be(true)

    space_type.update!(facilities: [facility])

    expect(space.reload.relevance_of_facility(other_facility)).to be(false)
  end

  it "sets relevance if a Space Type is added to a space" do
    new_space_type = Fabricate(:space_type)

    other_facility = Fabricate(:facility, space_types: [new_space_type])

    expect(space.reload.relevance_of_facility(other_facility)).to be(false)

    space.update!(space_types: [new_space_type])

    expect(space.reload.relevance_of_facility(other_facility)).to be(true)
  end

  it "removes relevance if a Space Type is removed from a Space" do
    expect(space.reload.relevance_of_facility(facility)).to be(true)

    space.update!(space_types: [])

    expect(space.reload.relevance_of_facility(facility)).to be(false)
  end

  it "allows setting descriptions for facilities, and keeping them after specific aggregation" do
    description = "This is a description"
    space.aggregate_facility_reviews(facilities: [facility])

    space_facility = SpaceFacility.find_by(space:, facility:)
    space_facility.update!(description:)

    space.aggregate_facility_reviews(facilities: [facility])

    expect(space_facility.reload.description).to eq(description)
  end

  it "does not touch the descriptions of space facilities, even after a broad aggregation" do
    before_space_facility = SpaceFacility.find_by(space:, facility:)
    before_space_facility.update!(description: "old description")

    expect(before_space_facility.reload.description).to eq("old description")

    space.aggregate_facility_reviews

    after_space_facility = SpaceFacility.find_by(space:, facility:)
    expect(after_space_facility.reload.description).to eq("old description")
  end

  it "does not update a space facility that does not need to change" do
    experience :was_allowed
    space_facility = SpaceFacility.find_by(space:, facility:)
    expect(space_facility.experience).to eq("likely")

    experience :was_allowed

    # No new ID
    after_space_facility = SpaceFacility.find_by(space:, facility:)
    expect(after_space_facility.id).to eq(space_facility.id)

    # And still the same experience:
    expect(space_facility.experience).to eq("likely")
  end

  it "is performant for a changing a single facility, even if there are a large amount of other facilities" do
    Array.new(20) { Fabricate(:facility, space_types: [space_type]) }
    expect { space.aggregate_facility_reviews(facilities: [facility]) }.to perform_under(30).ms
  end

  it "is performant for a large amount of facilities" do
    Array.new(20) { Fabricate(:facility, space_types: [space_type]) }
    expect { space.aggregate_facility_reviews }.to perform_under(50).ms
  end
end
