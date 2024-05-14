# frozen_string_literal: true

class PersonalSpaceList < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :spaces

  validates :title, presence: true

  def add_space(space)
    spaces << space
  end

  def remove_space(space)
    spaces.delete(space)
  end

  def includes_space?(space)
    spaces.include?(space)
  end

  def excludes_space?(space)
    spaces.exclude?(space)
  end
end

# == Schema Information
#
# Table name: personal_space_lists
#
#  id         :bigint           not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_personal_space_lists_on_user_id  (user_id)
#
