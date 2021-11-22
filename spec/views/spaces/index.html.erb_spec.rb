# frozen_string_literal: true

require "rails_helper"

RSpec.describe "spaces/index.html.erb", type: :view do
  it "renders the page" do
    assign(:space, Space.new)

    render

    expect(rendered).to match /space-listing/
    expect(rendered).to match /map-frame/
    # Cannot test that individual Spaces show up here since the render of them is triggered by Mapbox
  end
end
