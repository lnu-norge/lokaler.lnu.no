# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spaces::LocationSearchService do
  # These features require calls to geonorge for looking up data. VCR stores and replays the tests
  # They can be refreshed by simply deleting the test cassettes and restoring them again.
  include_context "with VCR for http calls"

  it "searches only on address" do
    expect(described_class.call(address: "Hammerstads gate 32").count).to eq(1)
  end

  it "searches only on postcode" do
    expect(described_class.call(post_number: 3060).count).to eq(10)
  end

  it "searches on address and postcode" do
    expect(described_class.call(address: "Ankerveien 2", post_number: 3060).count).to eq(9)
  end
end
