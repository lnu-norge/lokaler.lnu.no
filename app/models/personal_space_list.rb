# frozen_string_literal: true

class PersonalSpaceList < ApplicationRecord
  belongs_to :user

  has_one :active_personal_space_list, dependent: :destroy
  accepts_nested_attributes_for :active_personal_space_list
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

  def active
    active?
  end

  def active?
    active_personal_space_list.present?
  end

  def inactive?
    active_personal_space_list.blank?
  end

  def activate
    # Deactivate any active lists for this user
    ActivePersonalSpaceList.where(user:).destroy_all
    ActivePersonalSpaceList.create(user:, personal_space_list: self)
  end

  def deactivate
    active_personal_space_list.destroy if active?
  end

  # self.METHOD_NAME makes this a Class method, the others are instance methods
  # E.g it can be called like this: PersonalSpaceList.create_default_list_for(user)
  # instead of this: PersonalSpaceList.new.create_default_list_for(user)
  def self.create_default_list_for(user, active: true)
    default_list = order(updated_at: :desc).find_or_initialize_by(user:)
    if default_list.title.blank?
      default_list.update(title: I18n.t("personal_space_lists.default_list_name",
                                        name: user.name))
    end
    default_list.save
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
