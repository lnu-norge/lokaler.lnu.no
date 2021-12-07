class MakeSpaceGroupOptional < ActiveRecord::Migration[6.1]
  def change
    change_column_null :spaces, :space_group_id, true
    # Remove any empty SpaceGroups set by mistake earlier:
    SpaceGroup.where(title: "").destroy_all
  end
end
