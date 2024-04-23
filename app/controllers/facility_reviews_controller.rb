# frozen_string_literal: true

class FacilityReviewsController < BaseControllers::AuthenticateController
  include DefineFacilityParams
  include DefineGroupedFacilitiesForSpace
  include FacilityReviewsHelper

  before_action :require_facility_params,
                :set_space,
                :set_facility,
                :set_space_facility,
                :set_facility_review

  before_action :set_category,
                :set_experiences,
                only: %i[new show]

  def show; end

  def new; end

  def create
    save_review_data
    create_succeeded
  rescue StandardError
    create_failed
  end

  private

  def save_review_data
    # Data to save:
    params.permit(facility_review: [:user_id, :experience, :description])
    @user_id = params[:facility_review][:user_id]
    @experience = params[:facility_review][:experience]
    @description = params[:facility_review][:description]

    # Update the space facility first, then the facility review
    @space_facility.update(description: @description)

    # If the experience is unknown or not set, we do not store a review
    return @facility_review.destroy if @experience == "unknown" || @experience.blank?

    # Otherwise, update the review:
    @facility_review.update(
      experience: @experience
    )
  end

  def create_failed
    redirect_and_show_flash(flash_message: t("facility_reviews.error"),
                            flash_type: :alert,
                            redirect_status: :unprocessable_entity)
  end

  def create_succeeded
    redirect_and_show_flash(flash_message: t("reviews.added_review"))
  end

  def redirect_and_show_flash(flash_message:, flash_type: :notice, redirect_status: :ok)
    respond_to do |format|
      format.turbo_stream do
        flash.now[flash_type] = flash_message
        render turbo_stream: [
          turbo_stream.update(:flash,
                              partial: "shared/flash"),
          *turbo_streams_to_replace_facility_data
        ]
      end
      format.html do
        flash[flash_type] = flash_message
        # We redirect to space in case turbo is down or user
        # does not use JS. That's the most likely place they
        # want to go after submitting a review.
        redirect_to @space, status: redirect_status
      end
    end
  end

  def turbo_streams_to_replace_facility_data
    # Find all categories for the facility
    facility_categories = @facility.facility_categories

    facility_categories.map do |facility_category|
      turbo_stream.replace(
        target_id_for_categorized_facility(
          facility_id: @facility.id, category_id: facility_category.id, space_id: @space.id
        ),
        partial: "facility_reviews/facility_with_edit_button",
        locals: { facility: @facility.reload, facility_category:, space_facility: @space_facility.reload }
      )
    end
  end
end
