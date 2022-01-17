class AddOrganizationToUserReview < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :organization, :string, null: false, default: ""
    add_column :reviews, :organization, :string, null: false, default: ""
  end
end
