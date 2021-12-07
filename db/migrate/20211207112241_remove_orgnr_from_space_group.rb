class RemoveOrgnrFromSpaceGroup < ActiveRecord::Migration[6.1]
  def change
    remove_column :space_groups, :orgnr
  end
end
