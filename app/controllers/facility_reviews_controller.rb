# frozen_string_literal: true

class FacilityReviewsController < BaseControllers::AuthenticateController
  def new
    @space = Space.find(params["space_id"])
    @categories = FacilityCategory.all

    @reviews_for_categories = @space.reviews_for_categories(current_user)

    @grouped_relevant_facilities = @space.relevant_facilities(grouped: true)
    @non_relevant_facilities = @space.non_relevant_facilities
    @grouped_non_relevant_facilities = @space.group_space_facilities(@non_relevant_facilities)

    @experiences = [
      "unknown",
      *FacilityReview.experiences.keys.reverse
    ].reverse
  end

  def create
    @space = Space.find(params["space_id"])
    parsed = parse_facility_reviews(params["facility_reviews"]["reviews"])

    unless FacilityReview.create(parsed)
      render :new, status: :unprocessable_entity
      return
    end

    @space.aggregate_facility_reviews

    update_space_facilities

    create_success
  end

  def update_space_facilities
    params["space_facilities"].each do |space_facility|
      next if space_facility.second[:description].empty?

      sf = SpaceFacility.find_by(facility_id: space_facility.first, space: @space.id)
      sf.update!(description: space_facility.second[:description])
    end
  end

  def create_success
    flash_message = t("reviews.added_review")
    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = flash_message
        @grouped_relevant_facilities = @space.relevant_facilities(grouped: true)
        render turbo_stream: [
          turbo_stream.update(:flash,
                              partial: "shared/flash"),
          turbo_stream.update(:facilities,
                              partial: "spaces/show/facilities")
        ]
      end
      format.html do
        flash[:notice] = flash_message
        redirect_to @space
      end
    end
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

    delete_all_previous_reviews facility_review_values
  end

  # This should be done in the model, but I never figured out how.
  # I tried to .destroy and filter on before_validation, but
  # it only got roll-backed.
  def delete_all_previous_reviews(facility_reviews)
    ids = facility_reviews.filter_map do |review|
      review["id"] unless review["id"].empty?
    end

    FacilityReview.where(id: ids).destroy_all

    facility_reviews.delete_if { |review| review["experience"] == "unknown" }
    facility_reviews
  end
end
