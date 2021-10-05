# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FacilityCategory, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  it 'can create a facility category' do
    expect(Fabricate(:facility_category)).to be_truthy
  end
end
