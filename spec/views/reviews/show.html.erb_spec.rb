# frozen_string_literal: true

require "rails_helper"

RSpec.describe "reviews/show.html.erb", type: :view do
  let(:review) { Fabricate :review }

  it "renders the page" do
    assign(:review, review)
    render

    expect(rendered).to match /#{review.title}/
    expect(rendered).to match /#{review.comment}/
    expect(rendered).to match /#{review.price}/
    expect(rendered).to match /#{review.star_rating}/
  end
end
