# frozen_string_literal: true

require_relative "../../../db/seeds/imports/import_geo_data_over_api_functions"

namespace :geo do
  task "import_geographical_areas_from_geonorge" => :environment do
    load_fylker_from_geonorge
    load_kommuner_from_geonorge
  end
end
