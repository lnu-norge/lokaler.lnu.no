# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Review, type: :model do
  it 'can add a review' do
    review = Fabricate(:review)
    Fabricate(:facility_review, review: review)
    expect(review.title).to be_truthy
    expect(review.space).to be_truthy
    expect(review.comment).to be_truthy
    expect(review.price).to be_truthy
    expect(review.star_rating).to be_truthy
    expect(review.user).to be_truthy
    expect(review.facility_reviews.count).to be 1
  end

  it 'sets stars and facility_reviews for a Space when adding and removing a review' do
    space = Fabricate(:space)
    review = Fabricate(:review, space: space)
    facility = Fabricate(:facility)
    facility_review = Fabricate(
      :facility_review,
      review: review,
      facility: facility,
      space: space,
      experience: :was_not_allowed
    )

    space.reload

    expect(space.star_rating).to eq(review.star_rating)
    expect(space.reviews_for_facility(facility)).to eq('unlikely')

    review.destroy
    space.reload

    expect(space.star_rating).to be_nil
    expect(space.reviews_for_facility(facility)).to eq('unknown')
    expect { review.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { facility_review.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
