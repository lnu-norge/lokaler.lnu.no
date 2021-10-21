class ChangeStarRatingPrecision < ActiveRecord::Migration[6.1]
  def change
    change_column :spaces, :star_rating, :decimal, :precision => 2, :scale => 1
    change_column :reviews, :star_rating, :decimal, :precision => 2, :scale => 1
  end
end
