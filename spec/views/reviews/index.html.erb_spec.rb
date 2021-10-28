# frozen_string_literal: true

require "rails_helper"

RSpec.describe "reviews/index.html.erb", type: :view do
  let(:reviews) { Fabricate.times(3, :review) }

  it "renders the page" do
    assign(:reviews, reviews)
    render

    expect(rendered).to match /h1/
    expect(rendered).to match /form/
    expect(rendered).to match /#{reviews.first.title}/
    expect(rendered).to match /#{reviews.second.comment}/
    expect(rendered).to match /#{reviews.second.price}/
    expect(rendered).to match /#{reviews.third.star_rating}/
  end
end
