class AllowNullOrganizatoinOnReview < ActiveRecord::Migration[6.1]
  def change
    change_column :reviews, :organization_id, :integer, foreign_key: true, null: true
  end
end
