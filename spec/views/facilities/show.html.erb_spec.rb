# frozen_string_literal: true

require "rails_helper"

RSpec.describe "facilities/show", type: :view do
  let(:facility) { Fabricate :facility }

  it "renders the page" do
    assign(:facility, facility)
    render

    expect(rendered).to match /#{facility.title}/
    expect(rendered).to match /#{facility.icon}/
  end
end
