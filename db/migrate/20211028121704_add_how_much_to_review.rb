class AddHowMuchToReview < ActiveRecord::Migration[6.1]
  def change
    add_column :reviews, :how_much, :integer
    add_column :reviews, :how_much_custom, :string
  end
end
