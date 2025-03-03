# frozen_string_literal: true

require "rails_helper"

RSpec.describe FacilityReview, type: :model do
  it "can generate an review" do
    expect(Fabricate(:facility_review)).to be_truthy
  end

  it "can not create duplicate facility reviews for one space" do
    space = Fabricate(:space)
    user = Fabricate(:user)

    facility = Fabricate(:facility)

    Fabricate(
      :facility_review,
      facility:,
      space:,
      user:,
      experience: :was_not_allowed
    )
    expect(space.facility_reviews.count).to eq(1)

    # Generate a facility review for the same facility, should raise an error:
    expect do
      Fabricate(
        :facility_review,
        facility:,
        space:,
        user:,
        experience: :was_not_allowed
      )
    end.to raise_error(ActiveRecord::RecordInvalid)

    expect(space.facility_reviews.count).to eq(1)
  end
end
