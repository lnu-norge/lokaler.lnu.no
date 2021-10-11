class AddObjectChangesToVersions < ActiveRecord::Migration[6.1]
  def change
    # Adds diff to paper trail
    add_column :versions, :object_changes, :text
  end
end
