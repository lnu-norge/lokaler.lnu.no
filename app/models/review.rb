# frozen_string_literal: true

class Review < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :space

  after_save { space.aggregate_star_rating }
  after_destroy { space.aggregate_star_rating }
end

# == Schema Information
#
# Table name: reviews
#
#  id           :bigint           not null, primary key
#  comment      :string
#  organization :string           default(""), not null
#  star_rating  :decimal(2, 1)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  space_id     :bigint           not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_reviews_on_space_id  (space_id)
#  index_reviews_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (space_id => spaces.id)
#  fk_rails_...  (user_id => users.id)
#
