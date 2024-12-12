# frozen_string_literal: true

class RemoveSpaceUrl < ActiveRecord::Migration[7.2]
  def up
    move_old_url_data_to_space_contact

    change_table :spaces, bulk: true do |t|
      t.remove :url
    end
  end

  def down
    change_table :spaces, bulk: true do |t|
      t.string :url
    end

    restore_old_url_data_for_spaces_and_destroy_new_space_contacts
  end

  private

  def move_old_url_data_to_space_contact
    spaces_with_url.each do |space|
      create_space_contact_using_space_url(space)
    end
  end

  def spaces_with_url
    Space.where.not(url: [nil, ""])
  end

  def create_space_contact_using_space_url(space)
    return if space.url.blank?

    SpaceContact.create!(
      space: space,
      title: "Nettside",
      url: space.url,
      created_at: same_created_at_as_space(space)
    )
  end

  def restore_old_url_data_for_spaces_and_destroy_new_space_contacts
    space_contacts_created_by_this_script.each do |contact|
      contact.space.update(url: contact.url)
      contact.destroy
    end
  end

  def space_contacts_created_by_this_script
    SpaceContact
      .joins(:space)
      .where('space_contacts.created_at = spaces.created_at')
      .where('space_contacts.title = ?', 'Nettside')
  end

  def same_created_at_as_space(space)
    space.created_at
  end
end
