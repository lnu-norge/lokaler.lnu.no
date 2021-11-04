# frozen_string_literal: true

require "rails_helper"

RSpec.describe FacilityCategory, type: :model do
  it "can create a facility category" do
    expect(Fabricate(:facility_category)).to be_truthy
  end
end
