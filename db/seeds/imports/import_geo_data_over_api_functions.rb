# frozen_string_literal: true

# rubocop:disable Metrics/methodLength Metrics/AbcSize

require "net/http"
require "uri"
require "json"
require "rgeo/geo_json"

GEONORGE_API_SOURCE_NAME = "geonorge-api"

def load_geo_area_from_geonorge(uri_prefix, uri_id)
  uri = URI.parse("#{uri_prefix}/#{uri_id}/omrade")
  response = Net::HTTP.get_response(uri)
  omrade = JSON.parse(response.body)["omrade"]

  RGeo::GeoJSON.decode(omrade, geo_factory: Geo.factory)
end

FYLKE_API_END_POINT = "https://ws.geonorge.no/kommuneinfo/v1/fylker"
def load_fylker_from_geonorge
  geographical_area_type = GeographicalAreaType.find_or_create_by(name: "Fylke")

  Rails.logger.debug do
    "Loading fylker from API. We currently have: #{GeographicalArea.where(geographical_area_type:).count} fylker"
  end

  uri = URI.parse(FYLKE_API_END_POINT)
  response = Net::HTTP.get_response(uri)
  fylker = JSON.parse(response.body)

  Rails.logger.debug { "API has #{fylker.size} fylker to sync with" }

  fylker.each do |fylke|
    external_id = fylke["fylkesnummer"]

    fylke_in_db = GeographicalArea.find_or_create_by(unique_id_for_external_source: external_id,
                                                     geographical_area_type:)
    fylke_in_db.update(
      name: fylke["fylkesnavn"],
      external_source: GEONORGE_API_SOURCE_NAME,
      geo_area: load_geo_area_from_geonorge(FYLKE_API_END_POINT, external_id)
    )

    # throw "Error loading fylke #{external_id}: #{fylke_in_db.errors}" unless fylke_in_db.persisted?

    Rails.logger.debug { "\rLoaded #{external_id} #{fylke['fylkesnavn']}               " }
  end

  Rails.logger.debug "\rRemoving any fylker that are not in the API              \n"
  GeographicalArea
    .where(geographical_area_type:)
    .where.not(unique_id_for_external_source: fylker.pluck("fylkesnummer"))
    .destroy_all

  Rails.logger.debug do
    "\rLoaded fylker from API. We now have: #{GeographicalArea.where(geographical_area_type:).count} fylker     \n"
  end
end

KOMMUNE_API_END_POINT = "https://ws.geonorge.no/kommuneinfo/v1/kommuner"

def load_kommuner_from_geonorge
  geographical_area_type = GeographicalAreaType.find_or_create_by(name: "Kommune")

  Rails.logger.debug do
    "Loading kommuner from API. We currently have: #{GeographicalArea.where(geographical_area_type:).count} kommuner"
  end

  uri = URI.parse(KOMMUNE_API_END_POINT)
  response = Net::HTTP.get_response(uri)
  kommuner = JSON.parse(response.body)

  Rails.logger.debug { "API has #{kommuner.size} kommuner to sync with" }

  kommuner.each do |kommune|
    kommunenummer = kommune["kommunenummer"]
    fylkesnummer = kommunenummer[0..1] # First two digits are the fylkesnummer
    fylke = GeographicalArea.find_by(unique_id_for_external_source: fylkesnummer,
                                     geographical_area_type: GeographicalAreaType.find_by(name: "Fylke"))

    navn = kommune["kommunenavnNorsk"]
    # Add the Saami name if it exists
    navn += " (#{kommune['kommunenavn']})" if kommune["kommunenavn"] != kommune["kommunenavnNorsk"]

    kommune_in_db = GeographicalArea.find_or_create_by(unique_id_for_external_source: kommunenummer,
                                                       geographical_area_type:)

    kommune_in_db.update(
      name: navn,
      parent: fylke,
      external_source: GEONORGE_API_SOURCE_NAME,
      geo_area: load_geo_area_from_geonorge(KOMMUNE_API_END_POINT, kommunenummer)
    )

    # throw "Error loading kommune #{kommunenummer}: #{kommune_in_db.errors}" unless kommune_in_db.persisted?

    Rails.logger.debug { "\rLoaded #{kommunenummer} #{navn}             " }
  end

  Rails.logger.debug "\rRemoving any kommuner that are not in the API              \n"
  GeographicalArea
    .where(geographical_area_type:)
    .where.not(unique_id_for_external_source: kommuner.pluck("kommunenummer"))
    .destroy_all

  Rails.logger.debug do
    "\rLoaded kommuner from API. We now have: #{GeographicalArea.where(geographical_area_type:).count} kommuner    \n"
  end
end

# rubocop:enable Metrics/methodLength Metrics/AbcSize
