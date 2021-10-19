# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpaceOwner, type: :model do
  it 'can add a SpaceOwner with all attributes' do
    space_owner = described_class.create Fabricate.attributes_for(:space_owner)
    expect(space_owner).to be_valid
    expect(space_owner.about).to be_truthy
  end

  it 'can create a spaceOwner' do
    expect(Fabricate(:space_owner)).to be_truthy
  end
end
