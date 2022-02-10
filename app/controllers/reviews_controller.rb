# frozen_string_literal: true

class ReviewsController < BaseControllers::AuthenticateController
  before_action :set_review_from_id, only: [:show, :edit, :update]
  before_action :set_space_from_review, only: [:show, :edit, :update]
  before_action :authorize_user, only: [:edit, :update]

  def index
    @reviews = current_user.reviews
  end

  def show; end

  def create
    params = parse_before_create review_params
    @review = Review.new(params)
    @space = @review.space
    if @review.save
      create_success
    else
      create_error
    end
  end

  def new
    return if defined? @review

    @space = Space.find(params[:space_id])
    @review = @space.reviews.new(
      organization: current_user.organization
    )
  end

  def edit; end

  def update
    params = parse_before_update review_params, @review

    if @review.update(params)
      redirect_to space_path(@space)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def authorize_user
    return if @review.user && @review.user == current_user

    # TODO: This t(string) should be something like "You are not authorized".
    # TODO: Change it when the devise nb translations hit main.
    flash[:alert] = t("devise.failure.unauthenticated")
    redirect_back fallback_location: spaces_path
  end

  def set_review_from_id
    @review = Review.find(params[:id])
  end

  def set_space_from_review
    @space = @review.space
  end

  def create_success
    flash_message = t("reviews.added_review")
    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = flash_message
        render turbo_stream: [
          turbo_stream.update(:flash,
                              partial: "shared/flash"),
          turbo_stream.update(:reviews,
                              partial: "spaces/show/reviews")
        ]
      end
      format.html do
        flash[:notice] = flash_message
        redirect_to @space
      end
    end
  end

  def create_error
    render :new, status: :unprocessable_entity
  end

  def parse_before_update(review_params, _review)
    review_params
  end

  def parse_before_create(review_params)
    review_params["user"] = current_user
    review_params
  end

  def review_params
    case params[:review][:type_of_contact]
    when "been_there"
      params.require(:review).permit(
        :title, :comment,
        :price, :star_rating,
        :how_much, :how_much_custom,
        :how_long, :how_long_custom,
        :type_of_contact,
        :space_id,
        :organization
      )
    when "not_allowed_to_use"
      params.require(:review).permit(
        :title, :comment,
        :type_of_contact,
        :space_id,
        :organization
      )
    when "only_contacted"
      params.require(:review).permit(
        :title, :comment,
        :type_of_contact,
        :space_id,
        :organization
      )
    else
      raise "No valid type of contact given. Check reviews controller."
    end
  end
end
