# frozen_string_literal: true

class ChangeLatLonToDecimalInSpace < ActiveRecord::Migration[6.1]
  def change
    # rubocop:disable Rails/BulkChangeTable
    change_column :spaces, :lat, 'decimal USING CAST (lat as decimal)', precision: 10, scale: 6
    change_column :spaces, :long, 'decimal USING CAST (long as decimal)', precision: 10, scale: 6
    rename_column :spaces, :long, :lng
    # rubocop:enable Rails/BulkChangeTable
  end
end
