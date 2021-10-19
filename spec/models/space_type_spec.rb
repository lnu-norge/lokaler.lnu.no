# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpaceType, type: :model do
  it 'can create a spaceType' do
    expect(Fabricate(:space_type)).to be_truthy
  end
end
