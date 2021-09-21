# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spaces::AggregateFacilityReviews, type: :service do
  let(:space) { Fabricate(:space) }
  let(:facility) { Fabricate(:facility, space: space) }

  it 'turns into maybe' do
    Fabricate(:facility_review, space: space, experience: 'was_allowed', facility: facility)
    Fabricate(:facility_review, space: space, experience: 'was_not_allowed', facility: facility)
    expect(space.reload.aggregated_facility_reviews.first.experience).to eq('maybe')
  end

  it 'turns into likely' do
    Fabricate(:facility_review, space: space, experience: 'was_allowed', facility: facility)
    Fabricate(:facility_review, space: space, experience: 'was_allowed_but_bad', facility: facility)
    expect(space.reload.aggregated_facility_reviews.first.experience).to eq('likely')
  end

  it 'turns into unlikely' do
    Fabricate(:facility_review, space: space, experience: 'was_not_allowed', facility: facility)
    Fabricate(:facility_review, space: space, experience: 'was_not_available', facility: facility)
    expect(space.reload.aggregated_facility_reviews.first.experience).to eq('unlikely')
  end
end
