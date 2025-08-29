# frozen_string_literal: true

require "rails_helper"

RSpec.describe SpaceFacility, type: :model do
  let!(:space_facility) do
    Fabricate(:space_facility, space: Fabricate(:space), facility: Fabricate(:facility), relevant: false)
  end

  context "when creating a new space_facility" do
    it "can create a new space facility" do
      expect { Fabricate(:space_facility, space: Fabricate(:space), facility: Fabricate(:facility)) }.not_to raise_error
    end

    it "has a score" do
      expect(space_facility.score).to be_a(Integer)
    end
  end

  context "when updating a space_facility" do
    it "can update a space facility" do
      expect { space_facility.update!(description: "new description") }.not_to raise_error
    end

    it "scores 1 if relevant" do
      expect(space_facility.score).to be 0
      expect { space_facility.relevant! }.not_to raise_error
      expect(space_facility.score).to be 1
    end

    it "scores -2 if impossible" do
      expect(space_facility.score).to be 0
      expect { space_facility.update!(experience: "impossible") }.not_to raise_error
      expect(space_facility.score).to be(-2)
    end

    it "scores -1 if unlikely" do
      expect(space_facility.score).to be 0
      expect { space_facility.update!(experience: "unlikely") }.not_to raise_error
      expect(space_facility.score).to be(-1)
    end

    it "scores 2 if maybe" do
      expect(space_facility.score).to be 0
      expect { space_facility.update!(experience: "maybe") }.not_to raise_error
      expect(space_facility.score).to be 2
    end

    it "scores 3 if likely" do
      expect(space_facility.score).to be 0
      expect { space_facility.update!(experience: "likely") }.not_to raise_error
      expect(space_facility.score).to be 3
    end
  end
end

# == Schema Information
#
# Table name: space_facilities
#
#  id          :bigint           not null, primary key
#  description :string
#  experience  :integer
#  relevant    :boolean          default(FALSE)
#  score       :integer          default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  facility_id :bigint           not null
#  space_id    :bigint           not null
#
# Indexes
#
#  index_space_facilities_on_facility_id               (facility_id)
#  index_space_facilities_on_space_id                  (space_id)
#  index_space_facilities_on_space_id_and_facility_id  (space_id,facility_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (facility_id => facilities.id)
#  fk_rails_...  (space_id => spaces.id)
#
