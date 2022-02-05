# frozen_string_literal: true

Fabricator(:review) do
  title { Faker::Lorem.sentence(word_count: 4) }
  comment { Faker::Lorem.sentences }
  price { Faker::Number.number(digits: 3) }
  star_rating { Faker::Number.between(from: 1, to: 5) }
  organization { Faker::Name.name }
  type_of_contact { :been_there }
  user
  space
end

# == Schema Information
#
# Table name: reviews
#
#  id              :bigint           not null, primary key
#  comment         :string
#  how_long        :integer
#  how_long_custom :string
#  how_much        :integer
#  how_much_custom :string
#  organization    :string           default(""), not null
#  price           :string
#  star_rating     :decimal(2, 1)
#  title           :string
#  type_of_contact :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  space_id        :bigint           not null
#  user_id         :bigint           not null
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
