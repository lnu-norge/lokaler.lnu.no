# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spaces::AggregateStarRatingService do
  let(:space) { Fabricate(:space) }

  it 'rating equal 4' do
    Fabricate(:review, space: space, star_rating: 3)
    Fabricate(:review, space: space, star_rating: 5)
    Fabricate(:review, space: space, star_rating: 5)
    Fabricate(:review, space: space, star_rating: 4)

    expect(space.reload.star_rating).to eq((3.0 + 5.0 + 5.0 + 4.0) / 4)
  end
end
