# frozen_string_literal: true

require "rails_helper"

RSpec.describe "space_groups/index.html.erb", type: :view do
  let(:space_groups) { Fabricate.times(3, :space_group) }

  it "renders the page" do
    assign(:space_groups, space_groups)
    render

    expect(rendered).to match /h1/
    expect(rendered).to match /form/
    expect(rendered).to match /trix-content/
    expect(rendered).to match /#{space_groups.first.title}/
    expect(rendered).to match /#{space_groups.second.title}/
    expect(rendered).to match /#{space_groups.third.title}/
  end
end
