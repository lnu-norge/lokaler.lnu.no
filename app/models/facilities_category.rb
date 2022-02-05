# frozen_string_literal: true

class FacilitiesCategory < ApplicationRecord
  belongs_to :facility
  belongs_to :facility_category
end

# == Schema Information
#
# Table name: facilities_categories
#
#  id                   :bigint           not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  facility_category_id :bigint           not null
#  facility_id          :bigint           not null
#
# Indexes
#
#  index_facilities_categories_on_facility_category_id  (facility_category_id)
#  index_facilities_categories_on_facility_id           (facility_id)
#
# Foreign Keys
#
#  fk_rails_...  (facility_category_id => facility_categories.id)
#  fk_rails_...  (facility_id => facilities.id)
#
