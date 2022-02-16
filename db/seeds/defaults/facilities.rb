# frozen_string_literal: true

facilities = {
  "Vanlige rom": %w[
    Møterom
    Klasserom
  ],
  "Store rom": [
    "Auditorium",
    "Gymsal",
    "Idrettshall / Flerbrukshall",
    "Scene"
  ],
  Overnatting: [
    "Senger",
    "Sove på gulvet"
  ],
  "Musikk og dans": [
    "Øvingsrom",
    "Scene",
    "Dansegulv",
    "Tilgang på instrumenter"
  ],
  Internett: [
    "Wifi",
    "Mer enn normalt godt nett"
  ],
  Strøm: [
    "Mer enn normalt mye strøm",
    "Strømuttak"
  ],
  Kontorutstyr: [
    "Prosjektor",
    "Kopimaskin / skriver"
  ],
  "Lyd og lys": %w[
    Høytaleranlegg
    Mikrofon
    Lysanlegg
    Mixebrett
  ],

  "Lage egen mat:": [
    "Lov å spise medbrakt",
    "Kaffemaskin / vannkoker",
    "Mikrobølgeovn",
    "Kjøkken med ovn",
    "Låne kiosk-luke",
    "Kjøleskap"
  ],

  "Kjøpe mat der": %w[
    Kantine
    Catering
    Kiosk
  ],

  "Spesielt for hytter": [
    "Vinterisolert",
    "Mulig å kjøre helt opp til?"
  ],

  "Universell utforming": [
    "Rullestolvennlig inngang",
    "Rullestolvennlig inne",
    "HC-toalett",
    "Ledelinje",
    "Teleslynge",
    "Sanserom"
  ],

  Lagring: [
    "Skap tilgjengelig mellom økter",
    "Lagringsrom tilgjengelig mellom økter"
  ],

  Transport: [
    "Nær kollektiv",
    "Parkering"
  ],

  "Kreative rom": %w[
    Streaming-rom
    Podcast-rom
    Filmstudio
    Fotostudio
    Makerspace
    Sløydrom
    Syrom
  ],

  Skolerom: %w[
    Kjemirom
    Biologirom
    Andre skolerom
  ],

  Treningsrom: %w[
    Trimrom
    Vektløftingsrom
    Turnrom
    Andre treningsrom
  ],

  Idrettsbaner: [
    "Idrettshall / Flerbrukshall",
    "Gymsal",
    "Gress",
    "Kunstgress",
    "Grus",
    "Is",
    "Asfalt",
    "Sand"
  ]
}

# Create them all
facilities.each do |parent|
  category_title = parent.first
  category = FacilityCategory.find_or_create_by title: category_title

  facility_titles = parent.second
  facility_titles.each do |facility_title|
    facility = Facility.find_or_create_by(
      title: facility_title
    )
    facility.facility_categories = [
      category,
      *facility.facility_categories.all
    ].uniq
  end
end
