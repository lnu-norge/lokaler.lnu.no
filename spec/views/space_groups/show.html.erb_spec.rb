# frozen_string_literal: true

require "rails_helper"

RSpec.describe "space_groups/show", type: :view do
  let(:space_group) { Fabricate :space_group }

  it "renders the page" do
    assign(:space_group, space_group)
    render

    expect(rendered).to match /#{space_group.title}/
    expect(rendered).to match /#{space_group.about}/
    expect(rendered).to match /#{space_group.how_to_book}/
    expect(rendered).to match /#{space_group.terms}/
    expect(rendered).to match /#{space_group.pricing}/
    expect(rendered).to match /#{space_group.who_can_use}/
  end
end
