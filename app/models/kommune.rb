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
