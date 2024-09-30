# frozen_string_literal: true

class Kommune < GeographicalArea
  default_scope { where(geographical_area_type: GeographicalAreaType.find_by(name: "Kommune")) }

  before_validation :set_geographical_area_type

  private

  def set_geographical_area_type
    self.geographical_area_type = GeographicalAreaType.find_or_create_by(name: "Kommune")
  end
end
