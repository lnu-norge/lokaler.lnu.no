# frozen_string_literal: true

class AddDeletedToSpaces < ActiveRecord::Migration[8.0]
  def change
    add_column :spaces, :deleted, :boolean, default: false, null: false
  end
end
