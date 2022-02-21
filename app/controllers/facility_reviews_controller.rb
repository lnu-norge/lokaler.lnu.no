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
    @space = Space.find(params["space_id"])
    affected_facility_ids = []

    parsed = parse_facility_reviews(params["facility_reviews"]["reviews"], affected_facility_ids)

    unless FacilityReview.create(parsed)
      render :new, status: :unprocessable_entity
      return
    end

    affected_facilities = Facility.where(id: affected_facility_ids.uniq)
    @space.aggregate_facility_reviews(facilities: affected_facilities)

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

  private

  def parse_facility_reviews(raw_data, affected_facility_ids)
    # Converting to .values exists solely because I didn't manage to create a
    # form with radio buttons that sent the facility_reviews in a way that could
    # be automatically picked up by Rails AND still be seen as individual in the form itself.
    # Thus, we have to parse what is sent from the form here into something
    # that more closely resembles what the model expects:
    # Changes welcome!
    facility_reviews = raw_data.values

    handle_changed(facility_reviews, affected_facility_ids)
  end

  # Does two things:
  # 1. Destroys any existing reviews that are changed, and returns an array of new reviews to be created
  # 2. And mutates affected_facilities so we can aggregate facilities for those
  def handle_changed(facility_reviews, affected_facility_ids) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    facility_reviews.filter_map do |review|
      # We minimum need these to do anything useful
      next unless review[:user_id].present? && review[:facility_id].present? && review[:space_id].present?

      existing_review = FacilityReview.find_by(user_id: review[:user_id],
                                               facility_id: review[:facility_id],
                                               space_id: review[:space_id])

      # NB: Unknown experiences do not crate reviews. Thus existing_review.blank? is the same as
      # experience == "unknown"
      nothing_changed = (existing_review.blank? && review["experience"] == "unknown") ||
                        (existing_review.present? && existing_review[:experience] == review["experience"])

      next if nothing_changed

      # Something changed, so add facility to affected facilities
      affected_facility_ids << review["facility_id"]

      # Destroy the old review, so we are ready to return a new review for creation.
      existing_review.destroy if existing_review.present?

      # Unknown experiences do not crate reviews.
      next if review["experience"] == "unknown"

      review
    end
  end
end
