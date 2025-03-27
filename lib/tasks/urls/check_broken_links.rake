# frozen_string_literal: true

require "net/http"
require "uri"
require "parallel"

# Quick and dirty script that was written together with an AI. Counts broken links.
namespace :urls do # rubocop:disable Metrics/BlockLength
  desc "Check for broken URLs in Space and SpaceContact models"
  task check: :environment do # rubocop:disable Metrics/BlockLength
    broken_links = { spaces: [], space_contacts: [] }
    total_checked = { spaces: 0, space_contacts: 0 }
    start_time = Time.current

    def parse_and_check_url(url)
      return nil if url.blank?

      uri = URI.parse(url)
      uri = URI.parse("http://#{url}") unless uri.scheme

      check_parsed_url(uri)
    end

    def check_parsed_url(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.open_timeout = 2
      http.read_timeout = 2
      http.ssl_timeout = 2

      response = http.head(uri.path.presence || "/")

      return response.code if response.is_a?(Net::HTTPClientError)
      return response.code if response.is_a?(Net::HTTPServerError)

      nil
    rescue Net::OpenTimeout, Net::ReadTimeout
      "Error: Timeout"
    rescue StandardError => e
      "Error: #{e.message}"
    end

    puts "\n\nChecking SpaceContact URLs..."
    contact_urls = SpaceContact.where.not(url: [nil, ""]).pluck(:id, :space_id, :title, :url)
    results = Parallel.map(contact_urls, in_threads: 10) do |id, space_id, title, url|
      total_checked[:space_contacts] += 1
      print "."

      result = parse_and_check_url(url)
      { id: id, space_id: space_id, title: title, error: result } if result.present?
    end
    broken_links[:space_contacts] = results.compact

    end_time = Time.current
    duration = (end_time - start_time).round(2)

    puts "\n\nResults (completed in #{duration} seconds):"

    puts "\nChecked #{total_checked[:space_contacts]} SpaceContact URLs"
    puts "Found #{broken_links[:space_contacts].length} broken SpaceContact URLs:"
    broken_links[:space_contacts].each do |link|
      puts "SpaceContact ##{link[:id]} (Space ##{link[:space_id]} - #{link[:title]}): #{link[:error]}"
    end
  end
end
