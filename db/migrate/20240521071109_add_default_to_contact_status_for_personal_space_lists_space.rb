class AddDefaultToContactStatusForPersonalSpaceListsSpace < ActiveRecord::Migration[7.1]
  def change
    change_column_default :personal_space_lists_spaces, :contact_status, from: nil, to: 0

    PersonalSpaceListsSpace.where(contact_status: nil).update_all(contact_status: 0)
  end
end
