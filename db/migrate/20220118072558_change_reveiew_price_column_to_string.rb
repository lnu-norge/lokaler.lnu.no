class ChangeReveiewPriceColumnToString < ActiveRecord::Migration[6.1]
  def change
    change_column :reviews, :price, :string
  end
end
