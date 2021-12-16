# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spaces::AggregateFacilityReviewsService do
  let(:space) { Fabricate(:space) }
  let(:facility_category) { Fabricate(:facility_category) }
  let(:facility) { Fabricate(:facility, facility_category: facility_category) }

  def experience(experience, other_facility = nil)
    Fabricate(:facility_review, space: space, experience: experience, facility: other_facility || facility)
    space.reload.aggregate_facility_reviews
  end

  it "turns into maybe if there are mixed reviews" do
    experience :was_allowed
    experience :was_not_allowed
    expect(space.reload.reviews_for_facility(facility)).to eq("maybe")
  end

  it "turns into likely if there are over 2/3 positive reviews" do
    experience :was_not_allowed
    3.times { experience :was_allowed }
    expect(space.reload.reviews_for_facility(facility)).to eq("likely")
  end

  it "turns into likely if there are over 2/3 positive reviews, even if those are only the last five" do
    10.times { experience :was_not_allowed }
    4.times { experience :was_allowed }
    expect(space.reload.reviews_for_facility(facility)).to eq("likely")
  end

  it "turns into impossible if half or more say it does not exist (out of a minimum of 2)" do
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
    expect(space.reload.aggregated_facility_reviews.first.experience).to eq("unknown")

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
  end
end
