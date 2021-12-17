# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spaces::DuplicateDetectorService do
  let(:space) { Fabricate(:space, title: "First space") }
  #  let(:space_2) { Fabricate(:space, title: "Second space") }
  # let(:space_3) { Fabricate(:space, title: "Third space") }

  it "finds a potential duplicate based on title" do
    duplicate_space = Space.new(title: space.title)
    expect(duplicate_space.potential_duplicates).to eq([space])
  end

  it "finds several potential duplicates based on address" do
    duplicate_space = Space.new(
      address: space.address,
      post_number: space.post_number,
      post_address: space.post_address
    )
    expect(duplicate_space.potential_duplicates).to eq([space])
  end

  it "finds no duplicates if there are none" do
    new_space = Space.new(title: "Does not exist")
    expect(new_space.potential_duplicates).to eq(nil)
  end
end
