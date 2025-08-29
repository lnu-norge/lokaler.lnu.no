# frozen_string_literal: true

require "rails_helper"

RSpec.describe FacilityReview, type: :model do
  it "can generate an review" do
    expect(Fabricate(:facility_review)).to be_truthy
  end

  it "can not create duplicate facility reviews for one space" do
    space = Fabricate(:space)
    user = Fabricate(:user)

    facility = Fabricate(:facility)

    Fabricate(
      :facility_review,
      facility:,
      space:,
      user:,
      experience: :was_not_allowed
    )
    expect(space.facility_reviews.count).to eq(1)

    # Generate a facility review for the same facility, should raise an error:
    expect do
      Fabricate(
        :facility_review,
        facility:,
        space:,
        user:,
        experience: :was_not_allowed
      )
    end.to raise_error(ActiveRecord::RecordInvalid)

    expect(space.facility_reviews.count).to eq(1)
  end
end

# == Schema Information
#
# Table name: facility_reviews
#
#  id          :bigint           not null, primary key
#  experience  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  facility_id :bigint           not null
#  space_id    :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_facility_reviews_on_facility_id                           (facility_id)
#  index_facility_reviews_on_space_id                              (space_id)
#  index_facility_reviews_on_space_id_and_facility_id              (space_id,facility_id)
#  index_facility_reviews_on_space_id_and_user_id_and_facility_id  (space_id,user_id,facility_id) UNIQUE
#  index_facility_reviews_on_user_id                               (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (facility_id => facilities.id)
#  fk_rails_...  (space_id => spaces.id)
#  fk_rails_...  (user_id => users.id)
#
