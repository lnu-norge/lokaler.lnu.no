class AddUrlToSpace < ActiveRecord::Migration[6.1]
  def change
    add_column :spaces, :url, :string
  end
end
