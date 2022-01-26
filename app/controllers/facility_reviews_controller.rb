# frozen_string_literal: true

class FacilityReviewsController < AuthenticateController
  def new
    @categories = FacilityCategory.all
    @space = Space.find(params["space_id"])
  end

  def create
    @space = Space.find(params["space_id"])
    parsed = parse_facility_reviews(params["facility_reviews"])
    FacilityReview.create!(parsed)

    @space.aggregate_facility_reviews
  end

  private

  def parse_facility_reviews(facility_reviews)
    # Converting to .values exists solely because I didn't manage to create a
    # form with radio buttons that sent the facility_reviews in a way that could
    # be automatically picked up by Rails AND still be seen as individual in the form itself.
    # Thus, we have to parse what is sent from the form here into something
    # that more closely resembles what the model expects:
    # Changes welcome!
    facility_review_values = facility_reviews.values

    delete_all_unknown facility_review_values
  end

  # This should be done in the model, but I never figured out how.
  # I tried to .destroy and filter on before_validation, but
  # it only got roll-backed.
  def delete_all_unknown(facility_reviews)
    ids = facility_reviews.filter_map do |review|
      review["id"] if review["experience"] == "unknown"
    end

    FacilityReview.where(id: ids).destroy_all

    facility_reviews.delete_if { |review| review["experience"] == "unknown" }
    facility_reviews
  end
end
