# frozen_string_literal: true

require "rails_helper"

RSpec.describe Review, type: :model do
  it "can add a review" do
    review = Fabricate(:review)
    expect(review.space).to be_truthy
    expect(review.comment).to be_truthy
    expect(review.star_rating).to be_truthy
    expect(review.user).to be_truthy
  end
end
