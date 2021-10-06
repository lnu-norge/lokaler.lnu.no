# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spaces::AggregateFacilityReviewsService do
  let(:space) { Fabricate(:space) }
  let(:facility_category) { Fabricate(:facility_category) }
  let(:facility) { Fabricate(:facility, facility_category: facility_category) }

  it 'turns into maybe if there are mixed reviews' do
    Fabricate(:facility_review, space: space, experience: 'was_allowed', facility: facility)
    Fabricate(:facility_review, space: space, experience: 'was_not_allowed', facility: facility)
    expect(space.reload.reviews_for_facility(facility).experience).to eq('maybe')
  end

  it 'turns into likely if there are positive reviews' do
    Fabricate(:facility_review, space: space, experience: 'was_allowed', facility: facility)
    Fabricate(:facility_review, space: space, experience: 'was_allowed_but_bad', facility: facility)
    expect(space.reload.reviews_for_facility(facility).experience).to eq('likely')
  end

  it 'turns into impossible if the facility does not exist' do
    Fabricate(:facility_review, space: space, experience: 'was_not_allowed', facility: facility)
    Fabricate(:facility_review, space: space, experience: 'was_not_available', facility: facility)
    expect(space.reload.reviews_for_facility(facility).experience).to eq('impossible')
  end

  it 'turns into unlikely if there are negative reviews' do
    Fabricate(:facility_review, space: space, experience: 'was_not_allowed', facility: facility)
    Fabricate(:facility_review, space: space, experience: 'was_not_allowed', facility: facility)
    expect(space.reload.reviews_for_facility(facility).experience).to eq('unlikely')
  end

  it 'Is unknown if no reviews, and turns back into unknown if all facility reviews are deleted' do
    facility # ensure that the facility object is made
    space.facility_reviews.destroy_all
    expect(space.reload.aggregated_facility_reviews.first.experience).to eq('unknown')

    Fabricate(:facility_review, space: space, experience: 'was_not_allowed', facility: facility)
    Fabricate(:facility_review, space: space, experience: 'was_not_allowed', facility: facility)
    space.facility_reviews.destroy_all

    expect(space.reload.reviews_for_facility(facility).experience).to eq('unknown')
  end

  it 'Works even if there are unrelated facilities and reviews' do
    2.times do
      other_facility = Fabricate(:facility)
      Fabricate(:facility_review, space: space, experience: 'was_allowed', facility: other_facility)
    end
    Fabricate(:facility_review, space: space, experience: 'was_allowed', facility: facility)
    Fabricate(:facility_review, space: space, experience: 'was_not_allowed', facility: facility)
    expect(space.reload.reviews_for_facility(facility).experience).to eq('maybe')
  end
end
