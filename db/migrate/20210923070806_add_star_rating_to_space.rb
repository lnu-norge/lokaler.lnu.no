class AddStarRatingToSpace < ActiveRecord::Migration[6.1]
  def change
    add_column :spaces, :star_rating, :decimal, null: true
    change_column_null :reviews, :star_rating, true
  end
end
