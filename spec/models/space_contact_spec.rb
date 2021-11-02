# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpaceContact, type: :model do
  context 'when creating a new space_contact' do
    it 'can create a spaceContact for a space' do
      expect(Fabricate(:space_contact)).to be_truthy
    end

    it 'can create a spaceContact for a space_owner' do
      expect(Fabricate(:space_contact, space: nil)).to be_truthy
    end
  end

  context 'when updating a space_contact' do
    let(:space_contact) { Fabricate(:space_contact) }
    let(:title) { 'new title' }

    it 'can update a spaceContact for a space' do
      space_contact.update(title: title)
      expect(described_class.find_by(title: title)).to eq(space_contact)
    end
  end

  context 'when deleting a space_contact' do
    let(:space_contact) { Fabricate(:space_contact, title: 'title') }

    it 'can delete a space contact for a space' do
      space_contact.destroy
      expect(described_class.find_by(title: 'title')).to be_nil
    end
  end
end
