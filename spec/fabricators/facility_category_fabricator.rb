# frozen_string_literal: true

Fabricator(:facility_category) do
  title { Faker::Name.first_name }
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
