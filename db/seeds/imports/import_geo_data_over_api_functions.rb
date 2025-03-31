# frozen_string_literal: true

# Metrics/AbcSize

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
def load_fylker_from_geonorge # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Rails/Output

  # Create Fylke, if we do not have it:
  GeographicalAreaType.find_or_create_by(name: "Fylke")

  p "Loading fylker from API. We currently have: #{Fylke.count} fylker"

  uri = URI.parse(FYLKE_API_END_POINT)
  response = Net::HTTP.get_response(uri)
  fylker = JSON.parse(response.body)

  p "API has #{fylker.size} fylker to sync with"

  fylker.each do |fylke|
    external_id = fylke["fylkesnummer"]

    fylke_in_db = Fylke.find_or_create_by(unique_id_for_external_source: external_id)
    fylke_in_db.update(
      name: fylke["fylkesnavn"],
      external_source: GEONORGE_API_SOURCE_NAME,
      geo_area: load_geo_area_from_geonorge(FYLKE_API_END_POINT, external_id)
    )

    p fylke_in_db.errors.full_messages if fylke_in_db.errors.any?
    throw "Error loading fylke #{external_id}: #{fylke_in_db.errors.full_messages}" unless fylke_in_db.persisted?

    print "\rLoaded #{external_id} #{fylke['fylkesnavn']}               "
  end

  print "\rRemoving any fylker that are not in the API              \n"
  Fylke
    .where.not(unique_id_for_external_source: fylker.pluck("fylkesnummer"))
    .destroy_all

  print "\rLoaded fylker from API. We now have: #{Fylke.count} fylker     \n"

  # rubocop:enable Rails/Output
end

KOMMUNE_API_END_POINT = "https://ws.geonorge.no/kommuneinfo/v1/kommuner"

def load_kommuner_from_geonorge # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Rails/Output

  # Create Kommune, if we do not have it
  GeographicalAreaType.find_or_create_by(name: "Kommune")

  p "Loading kommuner from API. We currently have: #{Kommune.count} kommuner"

  uri = URI.parse(KOMMUNE_API_END_POINT)
  response = Net::HTTP.get_response(uri)
  kommuner = JSON.parse(response.body)
  # Exclude Oslo kommune. The fylke is enough:
  kommuner.reject! { |kommune| kommune["kommunenummer"] == "0301" }

  p "API has #{kommuner.size} kommuner to sync with"

  kommuner.each do |kommune|
    kommunenummer = kommune["kommunenummer"]
    fylkesnummer = kommunenummer[0..1] # First two digits are the fylkesnummer
    fylke = Fylke.find_by(unique_id_for_external_source: fylkesnummer)

    navn = kommune["kommunenavnNorsk"]
    # Add the Saami name if it exists
    navn += " (#{kommune['kommunenavn']})" if kommune["kommunenavn"] != kommune["kommunenavnNorsk"]

    kommune_in_db = Kommune.find_or_create_by(unique_id_for_external_source: kommunenummer)

    kommune_in_db.update(
      name: navn,
      parent: fylke,
      external_source: GEONORGE_API_SOURCE_NAME,
      geo_area: load_geo_area_from_geonorge(KOMMUNE_API_END_POINT, kommunenummer)
    )

    throw "Error loading kommune #{kommunenummer}: #{kommune_in_db.errors}" unless kommune_in_db.persisted?

    print "\rLoaded #{kommunenummer} #{navn}             "
  end

  print "\rRemoving any kommuner that are not in the API              \n"
  Kommune
    .where.not(unique_id_for_external_source: kommuner.pluck("kommunenummer"))
    .destroy_all

  count = Kommune.count
  print "\rLoaded kommuner from API. We now have: #{count} kommuner    \n"

  # rubocop:enable Rails/Output
end
