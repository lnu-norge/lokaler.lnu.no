# frozen_string_literal: true

require "rails_helper"

RSpec.describe FacilityReview, type: :model do
  it "can generate an review" do
    expect(Fabricate(:facility_review)).to be_truthy
  end
end
