# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpaceContact, type: :model do
  it 'can create a spaceContact for a space' do
    expect(Fabricate(:space_contact)).to be_truthy
  end

  it 'can create a spaceContact for a space_owner' do
    expect(Fabricate(:space_contact, space: nil)).to be_truthy
  end
end
