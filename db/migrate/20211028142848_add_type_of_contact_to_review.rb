class AddTypeOfContactToReview < ActiveRecord::Migration[6.1]
  def change
    add_column :reviews, :type_of_contact, :integer
  end
end
