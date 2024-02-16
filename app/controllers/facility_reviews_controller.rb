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

    return create_failed unless FacilityReview.create!(relevant_reviews)

    # NB: Under the current model, this needs to happen before we add the descriptions with update_space_facilities,
    # as aggregating DESTROYS all space_facilities, including the descriptions (wtf)
    @space.aggregate_facility_reviews(facilities: @affected_facilities)
    update_space_facilities(reviews_and_descriptions[:space_facilities_attributes].values)

    create_succeeded
  end

  private

  def create_failed
    redirect_and_show_flash(flash_message: t("reviews.error"), flash_type: :error,
                            redirect_status: :unprocessable_entity)
  end

  def create_succeeded
    redirect_and_show_flash(flash_message: t("reviews.added_review"))
  end

  def redirect_and_show_flash(flash_message:, flash_type: :notice, redirect_status: :ok)
    respond_to do |format|
      format.turbo_stream do
        flash.now[flash_type] = flash_message
        @grouped_relevant_facilities = @space.relevant_space_facilities(grouped: true)
        render turbo_stream: [
          turbo_stream.update(:flash,
                              partial: "shared/flash"),
          turbo_stream.update(:facilities,
                              partial: "spaces/show/facilities")
        ]
      end
      format.html do
        flash[flash_type] = flash_message
        redirect_to @space, status: redirect_status
      end
    end
  end

  def update_space_facilities(space_facilities)
    space_facilities.each do |facility|
      next if facility[:description].blank?

      SpaceFacility.find_by(facility_id: facility[:facility_id], space: @space.id)
                   .update!(description: facility[:description])
    end
  end

  # Does two things:
  # 1. Destroys any existing reviews that are changed, and returns an array of new reviews to be created
  # 2. And mutates affected_facilities so we can aggregate facilities for those
  def filtered_facility_reviews(facility_reviews)
    facility_reviews.filter_map do |review|
      next unless facility_review_has_required_params?(review)

      # Check if something is new or changed
      existing_review = find_existing_facility_review(review)
      next if nothing_changed(review, existing_review)

      # Destroy any old review, so we are ready to return a new review for creation.
      existing_review.destroy if existing_review.present?

      # Something changed, so add facility to affected facilities
      @affected_facilities << Facility.find(review["facility_id"])

      # Unknown experiences do not create reviews, so we can just skip creating a new one:
      next if review["experience"] == "unknown"

      # Space id is not in the form, we add it from params instead
      review["space_id"] = @space.id

      # New Facility Review, ready to be made!
      review
    end
  end

  def facility_review_has_required_params?(facility_review)
    # We minimum need these to do anything useful
    facility_review[:experience].present? &&
      facility_review[:user_id].present? &&
      facility_review[:facility_id].present? &&
      @space.id.present?
  end

  def find_existing_facility_review(review)
    existing_review = FacilityReview.find_by(id: review[:id]) if review[:id].present?
    return existing_review if existing_review.present?

    FacilityReview.find_by(
      facility_id: review[:facility_id],
      space_id: @space.id,
      user_id: review[:user_id]
    )
  end

  def nothing_changed(review, existing_review)
    # NB: Unknown experiences do not create reviews.
    # Thus existing_review.blank? is the same as
    # experience == "unknown"
    return true if existing_review.blank? && review["experience"] == "unknown"

    existing_review.present? && existing_review[:experience] == review["experience"]
  end
end
