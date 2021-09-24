# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spaces::AggregateFacilityReviewsService do
  let(:space) { Fabricate(:space) }
  let(:facility) { Fabricate(:facility, space: space) }

  it 'turns into maybe if there are mixed reviews' do
    Fabricate(:facility_review, space: space, experience: 'was_allowed', facility: facility)
    Fabricate(:facility_review, space: space, experience: 'was_not_allowed', facility: facility)
    expect(space.reload.aggregated_facility_reviews.first.experience).to eq('maybe')
  end

  it 'turns into likely if there are positive reviews' do
    Fabricate(:facility_review, space: space, experience: 'was_allowed', facility: facility)
    Fabricate(:facility_review, space: space, experience: 'was_allowed_but_bad', facility: facility)
    expect(space.reload.aggregated_facility_reviews.first.experience).to eq('likely')
  end

  it 'turns into impossible if the facility does not exist' do
    Fabricate(:facility_review, space: space, experience: 'was_not_allowed', facility: facility)
    Fabricate(:facility_review, space: space, experience: 'was_not_available', facility: facility)
    expect(space.reload.aggregated_facility_reviews.first.experience).to eq('impossible')
  end

  it 'turns into unlikely if there are negative reviews' do
    Fabricate(:facility_review, space: space, experience: 'was_not_allowed', facility: facility)
    Fabricate(:facility_review, space: space, experience: 'was_not_allowed', facility: facility)
    expect(space.reload.aggregated_facility_reviews.first.experience).to eq('unlikely')
  end

  it 'Is unknown if no reviews, and turns back into unknown if all facility reviews are deleted' do
    facility # ensure that the facility object is made
    space.facility_reviews.destroy_all
    expect(space.reload.aggregated_facility_reviews.first.experience).to eq('unknown')

    Fabricate(:facility_review, space: space, experience: 'was_not_allowed', facility: facility)
    Fabricate(:facility_review, space: space, experience: 'was_not_allowed', facility: facility)
    space.facility_reviews.destroy_all

    expect(space.reload.aggregated_facility_reviews.first.experience).to eq('unknown')
  end
end
