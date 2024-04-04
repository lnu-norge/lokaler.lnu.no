# frozen_string_literal: true

require "rails_helper"

RSpec.describe "spaces/index.html.erb", type: :view do
  it "renders the page" do
    assign :spaces, [Fabricate(:space)]
    assign :filterable_facility_categories, [Fabricate(:facility_category)]
    assign :filterable_space_types, [Fabricate(:space_type)]

    render

    expect(rendered).to match(/space-listing/)
    expect(rendered).to match(/map-frame/)
    # Cannot test that individual Spaces show up here since the render of them is triggered by Mapbox
  end
end
