# frozen_string_literal: true

class AddSpaceTypeToSpace < ActiveRecord::Migration[6.1]
  def change
    add_reference :spaces, :space_type, foreign_key: true
  end
end
