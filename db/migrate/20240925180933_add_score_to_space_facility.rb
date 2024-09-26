class AddScoreToSpaceFacility < ActiveRecord::Migration[7.1]
  def up
    add_column :space_facilities, :score, :integer, default: 0

    # In a transaction, calculate score for all space facilities
    SpaceFacility.transaction do
      count = SpaceFacility.count.to_i
      SpaceFacility.all.each_with_index do |space_facility, index|
        print  "\rCalculating score for #{index + 1} / #{count}        "
        space_facility.calculate_score
      end
    end
  end

  def down
    remove_column :space_facilities, :score
  end
end
