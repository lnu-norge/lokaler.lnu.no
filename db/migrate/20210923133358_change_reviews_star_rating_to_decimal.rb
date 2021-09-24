class ChangeReviewsStarRatingToDecimal < ActiveRecord::Migration[6.1]
  def change
    change_column :reviews, :star_rating, :decimal
  end
end
