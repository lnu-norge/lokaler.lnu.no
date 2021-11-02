class AddReferenceReviewOrganization < ActiveRecord::Migration[6.1]
  def change
    add_reference :reviews, :organization, foreign_key: true, null: false
  end
end
