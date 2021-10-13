# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpaceOwner, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  it 'can add a SpaceOwner with all attributes' do
    space_owner = described_class.create Fabricate.attributes_for(:space_owner)
    expect(space_owner).to be_valid
    expect(space_owner.about).to be_truthy
  end
end
