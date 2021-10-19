# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Space, type: :model do
  it 'can create a space' do
    expect(Fabricate(:space)).to be_truthy
  end
end
