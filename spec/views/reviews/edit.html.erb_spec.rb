# frozen_string_literal: true

require "rails_helper"

RSpec.describe "reviews/edit", type: :request do
  let(:user) { Fabricate :user }
  let(:review) { Fabricate :review, user: user }

  it "renders the page" do
    sign_in(user)
    get edit_review_path(review)

    rendered = response.body
    expect(rendered).to match /form/
    expect(rendered).to match /#{review.title}/
    expect(rendered).to match /#{review.comment}/
    expect(rendered).to match /#{review.price}/
    expect(rendered).to match /#{review.star_rating}/
    expect(rendered).to match /review_title/
    expect(rendered).to match /review_comment/
    expect(rendered).to match /review_price/
    expect(rendered).to match /review_star_rating/
    expect(rendered).to match /submit/
  end
end
