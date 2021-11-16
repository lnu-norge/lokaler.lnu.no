# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spaces::AggregateStarRatingService do
  let(:space) { Fabricate(:space) }

  it "Rating is calculated by averaging all reviews" do
    Fabricate(:review, space: space, star_rating: 3)
    Fabricate(:review, space: space, star_rating: 5)
    Fabricate(:review, space: space, star_rating: 5)
    Fabricate(:review, space: space, star_rating: 4)

    expect(space.reload.star_rating).to eq(4.3)
  end

  it "Rating equals nil if there are no reviews" do
    Fabricate(:review, space: space, star_rating: 3)
    Fabricate(:review, space: space, star_rating: 5)
    space.reviews.destroy_all

    expect(space.reload.star_rating).to eq(nil)
  end

  it "Rating can be calculated even if there are reviews with nil stars" do
    Fabricate(:review, space: space, star_rating: 3)
    Fabricate(:review, space: space, star_rating: 5)
    Fabricate(:review, space: space, star_rating: nil, type_of_contact: :only_contacted,
                       facility_reviews: [Fabricate(:facility_review)])

    expect(space.reload.star_rating).to eq((3.0 + 5.0) / 2)
  end
end
