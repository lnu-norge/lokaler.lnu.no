# frozen_string_literal: true

class PersonalSpaceList < ApplicationRecord
  belongs_to :user

  has_one :active_personal_space_list, dependent: :destroy
  accepts_nested_attributes_for :active_personal_space_list

  has_and_belongs_to_many :spaces

  has_many :personal_space_lists_shared_with_mes, dependent: :destroy
  has_many :personal_space_lists_spaces, dependent: :destroy
  has_many :personal_data_on_space_in_lists,
           dependent: :destroy,
           through: :personal_space_lists_spaces
  # Only return personal data on the space if the space is in the space list

  validates :title, presence: true

  def add_space(space)
    personal_space_lists_spaces.create_or_find_by(space:)
  end

  def remove_space(space)
    personal_space_lists_spaces.delete_by(space:)
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

  def activate_for(user:)
    deactivate_for(user:)
    ActivePersonalSpaceList.create(user:, personal_space_list: self)
  end

  def deactivate_for(user:)
    ActivePersonalSpaceList.where(user:).destroy_all
  end

  def space_count
    personal_data_on_space_in_lists.size
  end

  def space_contacted_count
    personal_data_on_space_in_lists.not_not_contacted.size
  end

  def space_not_contacted_count
    personal_data_on_space_in_lists.not_contacted.size
  end

  def space_said_no_count
    personal_data_on_space_in_lists.said_no.size
  end

  def space_said_maybe_count
    personal_data_on_space_in_lists.said_maybe.size
  end

  def space_said_yes_count
    personal_data_on_space_in_lists.said_yes.size
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

  def shared_with_public?
    shared_with_public
  end

  def start_sharing
    update(shared_with_public: true)
  end

  def stop_sharing
    update(shared_with_public: false)

    clean_up_shared_lists
  end

  def clean_up_shared_lists
    ActivePersonalSpaceList.where(personal_space_list: self).where.not(user:).destroy_all
  end

  def add_to_shared_with_user(user:)
    PersonalSpaceListsSharedWithMe.find_or_create_by(personal_space_list: self, user:)
  end

  def already_shared_with_user(user:)
    PersonalSpaceListsSharedWithMe.find_by(personal_space_list: self, user:).present?
  end

  def remove_from_shared_with_user(user:)
    PersonalSpaceListsSharedWithMe.where(personal_space_list: self, user:).destroy_all
    ActivePersonalSpaceList.where(personal_space_list: self, user:).destroy_all
  end
end

# == Schema Information
#
# Table name: personal_space_lists
#
#  id                 :bigint           not null, primary key
#  shared_with_public :boolean          default(FALSE)
#  title              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_id            :bigint
#
# Indexes
#
#  index_personal_space_lists_on_user_id  (user_id)
#
