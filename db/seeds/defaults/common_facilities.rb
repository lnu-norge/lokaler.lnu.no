# frozen_string_literal: true

# Default list of facilities

facilities = [
  {
    title: 'Overnatting',
    icon: 'sleepovers'
  },
  {
    title: 'Dusjer',
    icon: 'showers'
  },
  {
    title: 'Klasserom',
    icon: 'classroom'
  },
  {
    title: 'Auditorium',
    icon: 'auditorium'
  },
  {
    title: 'Gymsal',
    icon: 'gymnasium'
  },
  {
    title: 'Kjøkken',
    icon: 'kitchen'
  },
  {
    title: 'Spisesal',
    icon: 'dining_room'
  },
  {
    title: 'Prosjektor',
    icon: 'projector'
  }
]

category = FacilityCategory.find_or_create_by(title: 'Vanlige')

facilities.each do |facility|
  Facility.find_or_create_by(
    {
      facility_category: category,
      **facility
    }
  )
end