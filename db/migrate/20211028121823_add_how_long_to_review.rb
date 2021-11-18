class AddHowLongToReview < ActiveRecord::Migration[6.1]
  def change
    add_column :reviews, :how_long, :integer
    add_column :reviews, :how_long_custom, :string
  end
end
