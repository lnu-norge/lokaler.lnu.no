# frozen_string_literal: true

class FacilityReviewsController < BaseControllers::AuthenticateController
  def new
    @space = Space.find(params["space_id"])
    @categories = FacilityCategory.all

    @reviews_for_categories = @space.reviews_for_categories(current_user)

    @grouped_relevant_facilities = @space.relevant_space_facilities(grouped: true)
    @non_relevant_facilities = @space.non_relevant_space_facilities
    @grouped_non_relevant_facilities = @space.group_space_facilities(@non_relevant_facilities)

    @experiences = [
      "unknown",
      *FacilityReview.experiences.keys.reverse
    ].reverse
  end

  def create
    space_id_param = params.require(:space_id)
    reviews_and_descriptions = params.require(:space).permit(
      facility_reviews_attributes: %i[id experience facility_id user_id],
      space_facilities_attributes: [:facility_id, :description]
    )

    @space = Space.find(space_id_param)

    @affected_facilities = [] # filtered_facility_reviews will mutate this array
    relevant_reviews = filtered_facility_reviews(reviews_and_descriptions[:facility_reviews_attributes].values)

    return render :new, status: :unprocessable_entity unless FacilityReview.create!(relevant_reviews)

    # NB: Under the current model, this needs to happen before we add the descriptions,
    # as aggregating DELETES all space_facilities
    @space.aggregate_facility_reviews(facilities: @affected_facilities)

    update_space_facilities(reviews_and_descriptions[:space_facilities_attributes].values)

    create_success
  end

  private

  def update_space_facilities(space_facilities)
    space_facilities.each do |facility|
      next if facility[:description].blank?

      SpaceFacility.find_by(facility_id: facility[:facility_id], space: @space.id)
                   .update!(description: facility[:description])
    end
  end

  def create_success
    flash_message = t("reviews.added_review")
    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = flash_message
        @grouped_relevant_facilities = @space.relevant_space_facilities(grouped: true)
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

  # Does two things:
  # 1. Destroys any existing reviews that are changed, and returns an array of new reviews to be created
  # 2. And mutates affected_facilities so we can aggregate facilities for those
  def filtered_facility_reviews(facility_reviews) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    facility_reviews.filter_map do |review|
      # We minimum need these to do anything useful
      unless  review[:experience].present? &&
              review[:user_id].present? &&
              review[:facility_id].present? &&
              @space.id.present?
        next
      end

      existing_review = FacilityReview.find_by(user_id: review[:user_id],
                                               facility_id: review[:facility_id],
                                               space_id: @space.id)

      # NB: Unknown experiences do not create reviews. Thus existing_review.blank? is the same as
      # experience == "unknown"
      nothing_changed = (existing_review.blank? && review["experience"] == "unknown") ||
                        (existing_review.present? && existing_review[:experience] == review["experience"])

      next if nothing_changed

      # Something changed, so add facility to affected facilities
      @affected_facilities << Facility.find(review["facility_id"])

      # Destroy the old review, so we are ready to return a new review for creation.
      existing_review.destroy if existing_review.present?

      # Unknown experiences do not create reviews.
      next if review["experience"] == "unknown"

      # Add space_id to the review
      review["space_id"] = @space.id

      review
    end
  end
end
