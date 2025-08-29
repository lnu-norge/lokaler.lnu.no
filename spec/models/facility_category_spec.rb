# frozen_string_literal: true

require "rails_helper"

RSpec.describe FacilityCategory, type: :model do
  it "can create a facility category" do
    expect(Fabricate(:facility_category)).to be_truthy
  end
end

# == Schema Information
#
# Table name: facility_categories
#
#  id         :bigint           not null, primary key
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :bigint
#
# Indexes
#
#  index_facility_categories_on_parent_id  (parent_id)
#
