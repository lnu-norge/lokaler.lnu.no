# frozen_string_literal: true

class Review < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :space

  enum how_much: { custom_how_much: 0, whole_space: 1, one_room: 2 }
  enum how_long: { custom_how_long: 0, one_weekend: 1, one_evening: 2 }
  enum type_of_contact: { only_contacted: 0, not_allowed_to_use: 1, been_there: 2 }

  before_validation { remove_spaces_from_price }

  validates :title,
            length: { minimum: 4, maximum: 80 },
            presence: true,
            if: ->(r) { r.been_there? || r.not_allowed_to_use? }
  validates :how_much, inclusion: { in: how_muches.keys }, allow_nil: true
  validates :how_long, inclusion: { in: how_longs.keys }, allow_nil: true
  validates :type_of_contact, inclusion: { in: type_of_contacts.keys }
  validates :how_much_custom, presence: true, if: :custom_how_much?
  validates :how_long_custom, presence: true, if: :custom_how_long?
  validates :price, numericality: { greater_than: 0 }, allow_nil: true
  validates :star_rating, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, if: :been_there?

  # after_save { space.aggregate_facility_reviews }
  # after_destroy { space.aggregate_facility_reviews }

  after_save { space.aggregate_star_rating }
  after_destroy { space.aggregate_star_rating }

  # Allows user to input a number with spaces, e.g. "30 000", without the system breaking
  def remove_spaces_from_price
    price.gsub!(/\s+/, "") if price?.present?
  end

  ICONS_FOR_TYPE_OF_CONTACT = {
    "been_there" => "facility_status/likely",
    "not_allowed_to_use" => "facility_status/unlikely",
    "only_contacted" => "facility_status/unknown"
  }.freeze
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
