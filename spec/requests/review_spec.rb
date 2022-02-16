# frozen_string_literal: true

require "rails_helper"

RSpec.describe Review, type: :request do
  let(:user) { Fabricate(:user) }
  let(:review) { Fabricate(:review, user: user) }
  let(:space) { review.space }
  let(:facility) { Fabricate(:facility) }
  let(:facility_review) do
    Fabricate(
      :facility_review,
      space: space,
      user: user,
      facility: facility,
      experience: :was_not_allowed
    )
  end

  before do
    sign_in user
    facility_review.reload
    space.aggregate_facility_reviews
  end

  it "can load the new review path" do
    get new_review_path(space_id: space.id)
    expect(response).to have_http_status(:success)
  end

  it "can create a new review, show the review in Space#show, and show a flash message" do
    title = "They are all mean to me"
    expect(space.reviews.count).to eq(1)
    post reviews_path, params: {
      review: {
        title: title,
        type_of_contact: :not_allowed_to_use,
        space_id: space.id
      }
    }
    follow_redirect!
    expect(response).to have_http_status(:success)
    expect(space.reviews.count).to eq(2)

    # It shows a flash for the success
    expect(flash[:notice]).to match I18n.t("reviews.added_review")
  end

  it "can load the edit path" do
    get edit_review_path(review)
    expect(response).to have_http_status(:success)
  end
end
