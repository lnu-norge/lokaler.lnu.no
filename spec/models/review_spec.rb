# frozen_string_literal: true

require "rails_helper"

RSpec.describe Review, type: :model do
  it "can add a review" do
    review = Fabricate(:review)
    expect(review.space).to be_truthy
    expect(review.comment).to be_truthy
    expect(review.star_rating).to be_truthy
    expect(review.user).to be_truthy
  end
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
