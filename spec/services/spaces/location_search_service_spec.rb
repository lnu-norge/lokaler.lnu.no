# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spaces::LocationSearchService do
  it "searches only on address" do
    VCR.use_cassette("location_search_address") do
      expect(described_class.call(address: "Hammerstads gate 32").count).to eq(1)
    end
  end

  it "searches only on postcode" do
    VCR.use_cassette("location_search_postcode") do
      expect(described_class.call(post_number: 3060).count).to eq(10)
    end
  end

  it "searches on address and postcode" do
    VCR.use_cassette("location_search_address_postcode") do
      expect(described_class.call(address: "Ankerveien 2", post_number: 3060).count).to eq(1)
    end
  end
end
