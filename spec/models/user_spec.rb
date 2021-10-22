# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'can create a user' do
    expect(Fabricate(:user)).to be_truthy
  end
end
