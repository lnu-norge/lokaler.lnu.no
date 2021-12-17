# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spaces::DuplicateDetectorService, type: :request do
  let(:user) { Fabricate(:user) }
  let(:space) do
    Fabricate(:space,
              title: "Skolen min VGS",
              address: "Hammerstads gate 32",
              post_number: "0363",
              post_address: "Oslo")
  end

  before do
    sign_in user
    space.reload
  end

  it "finds several potential duplicates based on address" do
    Fabricate(:space,
              address: "Hammerstads gate 32",
              post_number: "0363",
              post_address: "Oslo")
    Fabricate(:space,
              address: "Hammerstads gate 32",
              post_number: "0363",
              post_address: "Oslo")

    duplicate_space = Space.new(
      address: space.address,
      post_number: space.post_number,
      post_address: space.post_address
    )
    expect(duplicate_space.potential_duplicates&.count).to eq(3)
  end

  it "finds no duplicates if there are none" do
    new_space = Space.new(title: "Does not exist", post_number: space.post_number)
    expect(new_space.potential_duplicates).to eq(nil)
  end

  it "finds potential duplicate based on partial match of title" do
    duplicate_space = Space.new(title: "Skolen min", post_number: space.post_number)
    expect(duplicate_space.potential_duplicates).to eq([space])
  end

  it "does not find a match if title matches, but not address" do
    new_space = Space.new(
      title: space.title,
      address: "Åbyggeveien 5",
      post_number: "1636",
      post_address: "Gamle Fredrikstad"
    )
    expect(new_space.potential_duplicates).to eq(nil)
  end

  it "finds a match if title, post number and post address matches, but not street address" do
    new_space = Space.new(
      title: space.title,
      address: "Hammerstads gate 34",
      post_number: space.post_number,
      post_address: space.post_address
    )
    expect(new_space.potential_duplicates).to eq([space])
  end

  it "finds a match if address matches, but not title" do
    duplicate_space = Space.new(
      title: "Finnes ikke denne da VGS",
      address: space.address,
      post_number: space.post_number,
      post_address: space.post_address
    )
    expect(duplicate_space.potential_duplicates).to eq([space])
  end

  it "can find duplicates calling the check_duplicates_path end point" do
    get check_duplicates_path, params: {
      title: "Skolen min", post_number: space.post_number
    }
    expect(response.body).to include(space.title)
  end

  it "can get negative results calling the check_duplicates_path end point" do
    get check_duplicates_path, params: {
      title: space.title,
      address: "Åbyggeveien 5",
      post_number: "1636",
      post_address: "Gamle Fredrikstad"
    }
    expect(JSON.parse(response.body)).to eq({ "html" => nil, "count" => 0 })
  end
end
