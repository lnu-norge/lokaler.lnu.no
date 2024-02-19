class RemoveTitleFromReview < ActiveRecord::Migration[7.1]

  # This class is a temporary model that allows us to access the reviews table in the database, even if it should be renamed in the future
  class ReviewModelForMigration < ApplicationRecord
    self.table_name = 'reviews'
  end

  def up
    # Removes the title column from the reviews table, and migrate any existing data to the top of the comment column

    # Migrate existing data to the top of the comment column
    ReviewModelForMigration.all.each do |review|
      next if review.title.blank?

      review.update(comment: "#{review.title}\n\n#{review.comment}")
    end

    # Then remove the title column
    remove_column :reviews, :title, :string
  end

  def down
    # Add the title column back to the reviews table
    add_column :reviews, :title, :string

    # Migrate the data from the top of the comment column back to the title column,
    # if it has a separate line for the title
    ReviewModelForMigration.all.each do |review|
      next if review.comment.blank?
      next unless review.comment.match?(/\A.*\n\n/) # If the first line does not contain a separate line for the title, we do not want to migrate it back

      title, comment = review.comment.split("\n\n", 2)
      review.update(title: title, comment: comment)
    end
  end
end
