# frozen_string_literal: true

require "rails_helper"

# Model test here, request spec follows below
RSpec.describe Review, type: :model do
  it "can add a review" do
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

  it "sets stars and facility_reviews for a Space when adding and removing a review" do
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
    expect(space.reviews_for_facility(facility)).to eq("unlikely")

    review.destroy
    space.reload

    expect(space.star_rating).to be_nil
    expect(space.reviews_for_facility(facility)).to eq("unknown")
    expect { review.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { facility_review.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "can create a review" do
    expect(Fabricate(:review)).to be_truthy
  end

  it 'can not create duplicate facility reviews' do
    review = Fabricate(:review)
    facility = Fabricate(:facility)
    Fabricate(
      :facility_review,
      review: review,
      facility: facility,
      experience: :was_not_allowed
    )
    expect(review.facility_reviews.count).to eq(1)

    # Generate a facility review for the same facility, should raise an error:
    expect do
      Fabricate(
        :facility_review,
        review: review,
        facility: facility,
        experience: :was_not_allowed
      )
    end.to raise_error(ActiveRecord::RecordInvalid)

    expect(review.facility_reviews.count).to eq(1)
  end
end

RSpec.describe Review, type: :request do
  let(:user) { Fabricate(:user) }
  let(:review) { Fabricate(:review, user: user) }
  let(:space) { review.space }
  let(:facility) { Fabricate(:facility) }

  before do
    sign_in user
    Fabricate(
      :facility_review,
      space: space,
      user: user,
      review: review,
      facility: facility,
      experience: :was_not_allowed
    )
  end

  it 'can load the edit path' do
    get edit_review_path(review)
    expect(response).to have_http_status(:success)
  end

  it 'has loaded the facility review, and set it to unlikely' do
    expect(review.facility_reviews.count).to eq(1)
    space.aggregate_facility_reviews
    expect(space.reviews_for_facility(facility)).to eq('unlikely')
  end

  it 'will update the facility review if the Review is updated' do
    patch review_path(review), params: {
      review: {
        facility_reviews_attributes: {
          "#{facility.id}": {
            facility_id: facility.id,
            experience: 'was_allowed'
          }
        }
      }
    }
    follow_redirect!
    expect(response).to have_http_status(:success)
    space.aggregate_facility_reviews
    expect(review.facility_reviews.count).to eq(1)
    expect(space.reviews_for_facility(facility.id)).to eq('likely')
  end

  it 'will delete the facility review if the Review is updated, and it is set to unknown' do
    expect(review.facility_reviews.count).to eq(1)
    patch review_path(review), params: {
      review: {
        facility_reviews_attributes: {
          "#{facility.id}": {
            facility_id: facility.id,
            experience: 'unknown'
          }
        }
      }
    }
    follow_redirect!
    expect(response).to have_http_status(:success)
    space.aggregate_facility_reviews
    expect(review.facility_reviews.count).to eq(0)
    expect(space.reviews_for_facility(facility.id)).to eq('unknown')
  end
end
