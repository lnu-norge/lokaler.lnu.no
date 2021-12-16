class CreateImages < ActiveRecord::Migration[6.1]
  def change
    create_table :images do |t|
      t.string :credits
      t.string :caption
      t.references :space
      t.timestamps
    end
  end
end
