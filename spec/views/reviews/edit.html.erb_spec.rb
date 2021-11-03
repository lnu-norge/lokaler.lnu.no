# frozen_string_literal: true

require "rails_helper"

RSpec.describe "reviews/edit", type: :view do
  let(:review) { Fabricate :review }

  it "renders the page" do
    assign(:review, review)
    render

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
