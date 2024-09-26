class AddScoreToSpaceFacility < ActiveRecord::Migration[7.1]
  def up
    add_column :space_facilities, :score, :integer, default: 0

    total_count = SpaceFacility.count.to_i
    processed_count = 0
    # In a transaction, calculate score for all space facilities
    SpaceFacility.find_in_batches(batch_size: 200) do |space_facilities|
      SpaceFacility.transaction do
        space_facilities.each do |space_facility|
          space_facility.calculate_score
          processed_count += 1
          print  "\rCalculated score for #{processed_count} / #{total_count}\r        "
        end
      end
    end
  end

  def down
    remove_column :space_facilities, :score
  end
end
