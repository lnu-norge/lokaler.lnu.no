# frozen_string_literal: true

Fabricator(:review) do
  comment { Faker::Lorem.sentences }
  star_rating { Faker::Number.between(from: 1, to: 5) }
  organization { Faker::Name.name }
  user
  space
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
