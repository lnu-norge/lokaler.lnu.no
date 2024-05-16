# frozen_string_literal: true

class PersonalSpaceList < ApplicationRecord
  belongs_to :user

  has_one :active_personal_space_list, dependent: :destroy
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

  def active?
    active_personal_space_list.present?
  end

  def activate
    ActivePersonalSpaceList.create(user:, personal_space_list: self)
  end

  def deactivate
    active_personal_space_list.destroy
  end

  # self.METHOD_NAME makes this a Class method, the others are instance methods
  # E.g it can be called like this: PersonalSpaceList.create_default_list_for(user)
  # instead of this: PersonalSpaceList.new.create_default_list_for(user)
  def self.create_default_list_for(user, active: true)
    default_list = create(user:, title: I18n.t("personal_space_lists.default_list_name", name: user.name))
    default_list.activate if active

    default_list
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
