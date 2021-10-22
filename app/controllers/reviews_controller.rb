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
