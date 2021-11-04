# frozen_string_literal: true

require "rails_helper"

RSpec.describe "space_owners/index.html.erb", type: :view do
  let(:space_owners) { Fabricate.times(3, :space_owner) }

  it "renders the page" do
    assign(:space_owners, space_owners)
    render

    expect(rendered).to match /h1/
    expect(rendered).to match /form/
    expect(rendered).to match /trix-content/
    expect(rendered).to match /#{space_owners.first.title}/
    expect(rendered).to match /#{space_owners.second.title}/
    expect(rendered).to match /#{space_owners.third.title}/
  end
end
