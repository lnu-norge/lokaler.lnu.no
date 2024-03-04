# frozen_string_literal: true

module Spaces
  class AggregateFacilityReviewsService
    module CountableReviews
      extend ActiveSupport::Concern

      private

      def most_recent_facility_reviews_for(facility)
        @grouped_facility_reviews[facility.id] || []
      end

      def group_recent_facility_reviews_by_facility(count: 5)
        @grouped_facility_reviews = @facility_reviews
                                    .group_by(&:facility_id)
                                    .transform_values { |reviews| reviews.first(count) }
      end

      def facility_reviews_for(facility)
        @last_five_facility_reviews_grouped_by_facility.find { |r| r.facility_id == facility.id }
      end

      def count_of_positive(reviews)
        # These keep performance high for this service, by keeping db calls to
        # a minimum. We could use the review.positive scope, but that would
        # require a db call for each review, which would be slow. We're only
        # counting in the already fetched list of reviews.
        count_of_reviews_with_experience(reviews, "was_allowed")
      end

      def count_of_negative(reviews)
        count_of_reviews_with_experience(reviews, "was_not_allowed")
      end

      def count_of_impossible(reviews)
        count_of_reviews_with_experience(reviews, "was_not_available")
      end

      def count_of_reviews_with_experience(reviews, experience)
        reviews.count { |r| r.experience == experience }
      end
    end
  end
end
