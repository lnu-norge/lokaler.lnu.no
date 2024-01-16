# frozen_string_literal: true

require "rails_helper"

# Model test here, requests spec follows below
RSpec.describe Review, type: :model do
  it "can add a review of type :been_there" do
    review = Fabricate(:review, type_of_contact: :been_there)
    expect(review.title).to be_truthy
    expect(review.space).to be_truthy
    expect(review.comment).to be_truthy
    expect(review.price).to be_truthy
    expect(review.star_rating).to be_truthy
    expect(review.user).to be_truthy
  end

  it "can add a review of type :not_allowed_to_use" do
    review = Fabricate(:review,
                       type_of_contact: :not_allowed_to_use,
                       price: nil,
                       star_rating: nil)
    expect(review.title).to be_truthy
    expect(review.space).to be_truthy
    expect(review.comment).to be_truthy
    expect(review.user).to be_truthy

    expect(review.price).to be_nil
    expect(review.star_rating).to be_nil
  end

  it "can add a review of type :only_contacted" do
    comment = "Some comment!"

    review = Fabricate(
      :review,
      type_of_contact: :only_contacted,
      price: nil,
      star_rating: nil,
      title: nil,
      comment:
    )

    expect(review.space).to be_truthy
    expect(review.user).to be_truthy

    expect(review.title).to be_nil
    expect(review.comment).to match comment
    expect(review.price).to be_nil
    expect(review.star_rating).to be_nil
  end

  it "sets stars for a Space when adding and removing a review" do
    space = Fabricate(:space)
    review = Fabricate(:review, space:)

    expect(space.star_rating).to eq(review.star_rating)

    review.destroy

    expect(space.star_rating).to be_nil
  end

  it "sets space_facility for space when adding and removing a facility_review" do
    space = Fabricate(:space)
    facility = Fabricate(:facility)
    facility_review = Fabricate(
      :facility_review,
      facility:,
      space:,
      experience: :was_not_allowed
    )

    space.aggregate_facility_reviews

    expect(space.reviews_for_facility(facility)).to eq("unlikely")

    facility_review.destroy

    space.aggregate_facility_reviews

    expect(space.reviews_for_facility(facility)).to eq("unknown")
  end

  it "can create a review" do
    expect(Fabricate(:review)).to be_truthy
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

  it "allows spaces in price user input" do
    review = Fabricate(:review, price: 10)
    review.price = "30 000"
    review.save!
    review.reload
    expect(review.price).to eq("30000")
  end
end
