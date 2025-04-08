# frozen_string_literal: true

module SyncingData
  module FromNsr
    # Cache handling for NSR sync service
    module CacheHelper
      # Cache for 30 days with TTL refresh on access
      CACHE_TTL = 30.days

      def serve_cached_data(cache_key, cached_data)
        Rails.logger.info("Using cached data for school #{cache_key.split(':').last}")
        # Extend the TTL by rewriting to cache with same data
        Rails.cache.write(cache_key, cached_data, expires_in: CACHE_TTL)
        cached_data[:data]
      end

      def cache_school_details(cache_key, data)
        cache_data = {
          data: data,
          date_changed_at_from_nsr: data["DatoEndret"],
          cached_at: Time.current.iso8601
        }

        Rails.cache.write(cache_key, cache_data, expires_in: CACHE_TTL)
      end

      def cache_still_fresh?(cached_data:, date_changed_at_from_nsr:)
        return false unless valid_cache_input?(cached_data, date_changed_at_from_nsr)

        parsed_dates = parse_dates(cached_data[:date_changed_at_from_nsr], date_changed_at_from_nsr)
        cached_changed_at, nsr_changed_at = parsed_dates

        return false unless cached_changed_at && nsr_changed_at

        # Cache is fresh if cached date is >= list date (not older)
        nsr_changed_at <= cached_changed_at
      end

      private

      def valid_cache_input?(cached_data, date_changed_at_from_nsr)
        date_changed_at_from_nsr.present? && cached_data.present?
      end

      def parse_dates(cached_date_string, nsr_date_string)
        cached_changed_at = safe_parse_time(cached_date_string)
        nsr_changed_at = safe_parse_time(nsr_date_string)

        [cached_changed_at, nsr_changed_at]
      end

      def safe_parse_time(time_string)
        Time.zone.parse(time_string)
      rescue StandardError
        nil
      end
    end
  end
end
