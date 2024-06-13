# frozen_string_literal: true

module SpaceFacilityHelper
  def css_class_for_space_facility_experience(experience)
    case experience
    when "likely"
      "text-green-500"
    when "unlikely", "impossible"
      "text-red-500"
    when "maybe"
      "text-yellow-500"
    else "text-gray-400"
    end
  end

  def facility_experience_to_space_facility_experience_translator(facility_experience)
    case facility_experience
    when "was_allowed"
      "likely"
    when "was_not_allowed"
      "unlikely"
    when "was_not_available"
      "impossible"
    else "unknown"
    end
  end

  def icon_for_facility_experience(experience)
    status = facility_experience_to_space_facility_experience_translator(experience)
    inline_svg_tag(
      "facility_status/#{status}",
      class: (" text-black " if status == "impossible").to_s
    )
  end

  def icon_for_space_facility_experience(experience)
    inline_svg_tag(
      "facility_status/#{experience}",
      class: (" text-black " if experience == "impossible").to_s
    )
  end
end
