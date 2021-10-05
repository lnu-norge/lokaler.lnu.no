# frozen_string_literal: true

# Default list of facilities

facilities = [
  {
    title: 'Inngang',
    icon: 'a11y_entrance'
  },
  {
    title: 'Toalett',
    icon: 'a11y_toilets'
  },
  {
    title: 'Ledelinje',
    icon: 'a11y_floor_guidelines'
  },
  {
    title: 'Teleslynge',
    icon: 'a11y_teleloop'
  },
  {
    title: 'Heis',
    icon: 'a11y_elevator'
  }
]

facilities.each do |facility|
  Facility.find_or_create_by(
    facility
  )
end
