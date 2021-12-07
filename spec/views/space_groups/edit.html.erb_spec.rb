# frozen_string_literal: true

require "rails_helper"

RSpec.describe "space_groups/edit", type: :view do
  let(:space_group) { Fabricate :space_group }

  it "renders the page" do
    assign(:space_group, space_group)
    render

    expect(rendered).to match /form/
    expect(rendered).to match /#{space_group.title}/
    expect(rendered).to match /space_group_how_to_book/
    expect(rendered).to match /space_group_terms/
    expect(rendered).to match /space_group_pricing/
    expect(rendered).to match /space_group_who_can_use/
    expect(rendered).to match /space_group_about/
    expect(rendered).to match /submit/
  end
end
