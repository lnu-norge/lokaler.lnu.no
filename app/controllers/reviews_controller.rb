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
    params = parse_before_create review_params
    @review = Review.create(params)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.prepend(:reviews,
                               partial: 'spaces/show/review_card',
                               locals: { review: @review }),
          turbo_stream.replace(:new_review_path,
                               partial: 'spaces/show/review_link_to_new_review',
                               locals: {
                                 space: @review.space
                               })
        ]
      end
      format.html { redirect_to @review.space }
    end
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

  def parse_before_create(review_params)
    review_params['facility_reviews_attributes'] = parse_facility_reviews(review_params)
    review_params['user'] = current_user
    review_params
  end

  def parse_facility_reviews(review_params)
    review_params['facility_reviews_attributes']
      .values
      .filter { |facility_review| facility_review[:experience] != 'unknown' }
      .map do |facility_review|
        facility_review[:user] = current_user
        facility_review[:space_id] = review_params['space_id']
        facility_review
      end
  end

  def review_params
    params.require(:review).permit(
      :title, :comment,
      :price, :star_rating,
      :how_much, :how_much_custom,
      :how_long, :how_long_custom,
      :type_of_contact,
      :space_id,
      facility_reviews_attributes: %i[facility_id experience]
    )
  end
end
