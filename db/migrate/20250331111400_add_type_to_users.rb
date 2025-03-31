# frozen_string_literal: true

class AddTypeToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :type, :string
    add_index :users, :type
  end
end
