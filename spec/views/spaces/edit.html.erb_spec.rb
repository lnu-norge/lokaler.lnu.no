# frozen_string_literal: true

require "rails_helper"

RSpec.describe "spaces/edit", type: :view do
  let(:space) { Fabricate :space }

  it "renders the page" do
    assign(:space, space)
    render

    expect(rendered).to match /form/
    expect(rendered).to match /#{space.title}/
    expect(rendered).to match /space_how_to_book/
    expect(rendered).to match /space_who_can_use/
    expect(rendered).to match /space_pricing/
    expect(rendered).to match /space_address/
    expect(rendered).to match /space_more_info/
    expect(rendered).to match /space_terms/
    expect(rendered).to match /submit/
  end
end
