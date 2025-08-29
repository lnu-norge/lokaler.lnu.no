# frozen_string_literal: true

class Kommune < GeographicalArea
  default_scope do
    where(geographical_area_type: GeographicalAreaType.find_by(name: "Kommune"))
      .order(:name)
  end
  belongs_to :fylke, class_name: "Fylke", foreign_key: :parent_id, inverse_of: :kommuner

  before_validation :set_geographical_area_type

  has_many :spaces, dependent: :nullify, inverse_of: :kommune

  private

  def set_geographical_area_type
    self.geographical_area_type = GeographicalAreaType.find_or_create_by(name: "Kommune")
  end
end

# == Schema Information
#
# Table name: geographical_areas
#
#  id                            :bigint           not null, primary key
#  external_source               :string
#  filterable                    :boolean          default(TRUE)
#  geo_area                      :geometry         not null, geometry, 0
#  name                          :string
#  order                         :integer
#  unique_id_for_external_source :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  geographical_area_type_id     :bigint
#  parent_id                     :bigint
#
# Indexes
#
#  index_geographical_areas_on_geo_area                   (geo_area) USING gist
#  index_geographical_areas_on_geographical_area_type_id  (geographical_area_type_id)
#  index_geographical_areas_on_parent_id                  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (geographical_area_type_id => geographical_area_types.id)
#  fk_rails_...  (parent_id => geographical_areas.id)
#
