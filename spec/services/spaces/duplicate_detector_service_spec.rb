# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spaces::DuplicateDetectorService do
  let(:space) { Fabricate(:space, title: "First space") }
  #  let(:space_2) { Fabricate(:space, title: "Second space") }
  # let(:space_3) { Fabricate(:space, title: "Third space") }

  it "finds a potential duplicate based on title" do
    expect(space.check_for_duplicate(title: space.title)).to eq([space])
  end

  it "finds several potential duplicates based on address" do
    expect(space.check_for_duplicate(address: space.address)).to eq([space])
  end

  it "finds no duplicates if there are none" do
    expect(space.check_for_duplicate(title: "Does not exist")).to eq([])
  end
end
