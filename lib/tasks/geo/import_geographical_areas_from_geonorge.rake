# frozen_string_literal: true

require_relative "../../../db/seeds/imports/import_geo_data_over_api_functions"

namespace :geo do
  task "import_geographical_areas_from_geonorge" => :environment do
    load_fylker_from_geonorge
    load_kommuner_from_geonorge
    Rake::Task["geo:set_geographical_areas_spaces_belong_to"].invoke
  end

  task "set_geographical_areas_spaces_belong_to" => :environment do
    Space.find_each do |space|
      Rails.logger.debug { "Setting geo data for space #{space.id}" }
      space.set_geo_data
      space.save!
    end
    Rails.logger.debug { "Finished setting geo data" }
  end
end
