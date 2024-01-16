# frozen_string_literal: true

Fabricator(:space_contact) do
  title { Faker::Name.name }
  telephone { "40482128" }
  telephone_opening_hours { "Open from: #{opening_hours(10, 5)} to #{opening_hours(4, 0)}" }
  email { Faker::Internet.email }
  url { Faker::Internet.url host: "example.com" }
  description { Faker::Lorem.sentence(word_count: 2, random_words_to_add: 3) }
  priority { Faker::Number.between(from: 1, to: 5) }
  space
  space_group
end

def opening_hours(start, stop)
  Faker::Time.between(from: DateTime.now - start, to: DateTime.now - stop)
end

# == Schema Information
#
# Table name: space_contacts
#
#  id                      :bigint           not null, primary key
#  description             :text
#  email                   :string
#  priority                :integer
#  telephone               :string
#  telephone_opening_hours :string
#  title                   :string
#  url                     :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  space_group_id          :bigint
#  space_id                :bigint
#
# Indexes
#
#  index_space_contacts_on_space_group_id  (space_group_id)
#  index_space_contacts_on_space_id        (space_id)
#
# Foreign Keys
#
#  fk_rails_...  (space_group_id => space_groups.id)
#  fk_rails_...  (space_id => spaces.id)
#
