# frozen_string_literal: true

class Fylke < GeographicalArea
  default_scope do
    where(
      geographical_area_type: GeographicalAreaType.find_by(name: "Fylke")
    )
      .order(:unique_id_for_external_source)
  end
  has_many :kommuner,
           class_name: "Kommune",
           foreign_key: :parent_id,
           inverse_of: :fylke,
           dependent: :destroy

  has_many :spaces, dependent: :nullify, inverse_of: :fylke

  before_validation :set_geographical_area_type

  private

  def set_geographical_area_type
    self.geographical_area_type = GeographicalAreaType.find_or_create_by(name: "Fylke")
  end
end
