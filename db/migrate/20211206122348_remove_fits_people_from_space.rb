class RemoveFitsPeopleFromSpace < ActiveRecord::Migration[6.1]
  def change
    # Not used, and not useful
    remove_column :spaces, :fits_people
  end
end
