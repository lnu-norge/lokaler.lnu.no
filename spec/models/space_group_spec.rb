# frozen_string_literal: true

require "rails_helper"

RSpec.describe SpaceGroup, type: :model do
  it "can create a spaceGroup" do
    expect(Fabricate(:space_group)).to be_truthy
  end
end
