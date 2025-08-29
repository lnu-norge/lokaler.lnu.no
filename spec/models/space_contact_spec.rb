# frozen_string_literal: true

require "rails_helper"

RSpec.describe SpaceContact, type: :model do
  context "when creating a new space_contact" do
    it "can create a spaceContact for a space" do
      expect { Fabricate(:space_contact) }.not_to raise_error
    end

    it "can create a spaceContact for a space_group" do
      expect { Fabricate(:space_contact, space: nil) }.not_to raise_error
    end

    it "can create a spaceContact for a space without space_group" do
      expect { Fabricate(:space_contact, space_group: nil) }.not_to raise_error
    end

    it "cannot create a spaceContact without space or space_group" do
      expect { Fabricate(:space_contact, space_group: nil, space: nil) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context "when updating a space_contact" do
    let(:space_contact) { Fabricate(:space_contact) }
    let(:title) { "new title" }

    it "can update a spaceContact for a space" do
      space_contact.update(title:)
      expect(described_class.find_by(title:)).to eq(space_contact)
    end
  end

  context "when deleting a space_contact" do
    let(:space_contact) { Fabricate(:space_contact, title: "title") }

    it "can delete a space contact for a space" do
      space_contact.destroy
      expect(described_class.find_by(title: "title")).to be_nil
    end
  end
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
