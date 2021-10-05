# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Facility, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  it 'can create a facility' do
    expect(Fabricate(:facility)).to be_truthy
  end
end
