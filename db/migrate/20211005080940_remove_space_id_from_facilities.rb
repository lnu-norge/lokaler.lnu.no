class RemoveSpaceIdFromFacilities < ActiveRecord::Migration[6.1]
  def change
    remove_reference :facilities, :space
  end
end
