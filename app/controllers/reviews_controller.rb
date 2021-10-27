# frozen_string_literal: true

class ReviewsController < AuthenticateController
  def index
    @reviews = Review.all
    @review = Review.new
  end

  def show
    @review = Review.find(params[:id])
  end

  def create
    @review = Review.create!(review_params)

    redirect_to reviews_path
  end

  def new
    @space = Space.find(params[:space_id])
    @review = Review.new(space: @space)
    @facilities_no_data = @space.aggregated_facility_reviews.unknown
    @facilities_has_data = @space.aggregated_facility_reviews.neither_unknown_nor_impossible
    @facilities_hidden = @space.aggregated_facility_reviews.impossible
  end

  def edit
    @review = Review.find(params[:id])
  end

  def update
    @review = Review.find(params[:id])

    if @review.update(review_params)
      redirect_to reviews_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def review_params
    params.require(:review).permit(:title, :comment, :price, :star_rating, :user_id, :space_id)
  end
end
