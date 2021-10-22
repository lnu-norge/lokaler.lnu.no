# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpaceOwner, type: :model do
  it 'can create a spaceOwner' do
    expect(Fabricate(:space_owner)).to be_truthy
  end
end
