# frozen_string_literal: true

require "rails_helper"

RSpec.describe PersonalSpaceList, type: :model do
  let!(:users_space_list) { Fabricate(:personal_space_list) }
  let(:user) { users_space_list.user }
  let(:space_to_add_to_list) { Fabricate(:space) }

  it "can generate a personal_space_list" do
    expect(users_space_list).to be_truthy
  end

  it "can destroy a list" do
    expect { users_space_list.destroy }.to change(described_class, :count).by(-1)
  end

  it "can destroy a list, even if it has a space" do
    space = Fabricate(:space)
    users_space_list.add_space(space)
    users_space_list.reload
    expect { users_space_list.destroy }.to change(described_class, :count).by(-1)
  end

  it "can share a list" do
    expect(users_space_list.shared_with_public).to be_falsey

    users_space_list.start_sharing

    expect(users_space_list.shared_with_public).to be_truthy
  end

  it "can stop sharing a list" do
    users_space_list.start_sharing
    expect(users_space_list.shared_with_public).to be_truthy

    users_space_list.stop_sharing
    expect(users_space_list.shared_with_public).to be_falsey
  end

  it "can activate and deactivate a list for a user" do
    expect(user.active_personal_space_list).to be_falsey
    users_space_list.activate_for(user:)
    expect(user.active_personal_space_list).to be_truthy
  end

  it "can add a space to the list" do
    expect { users_space_list.add_space(space_to_add_to_list) }.to change(users_space_list.spaces, :count).by(1)
  end

  it "can remove a space from the list" do
    users_space_list.add_space(space_to_add_to_list)
    expect { users_space_list.remove_space(space_to_add_to_list) }.to change(users_space_list.spaces, :count).by(-1)
  end

  it "can add personal data about a space in a list, without having it removed if the space is removed from the list" do
    users_space_list.add_space(space_to_add_to_list)
    personal_data = users_space_list.this_lists_personal_data_on_spaces.find_by(space: space_to_add_to_list)

    expect(personal_data.personal_notes).to be_nil
    expect(personal_data.contact_status).to eq("not_contacted")

    personal_data.update(
      personal_notes: "Foobar",
      contact_status: "said_no"
    )

    personal_data.reload
    expect(personal_data.personal_notes).to eq("Foobar")
    expect(personal_data.contact_status).to eq("said_no")

    users_space_list.remove_space(space_to_add_to_list)

    personal_data.reload
    expect(personal_data.personal_notes).to eq("Foobar")
    expect(personal_data.contact_status).to eq("said_no")
  end

  it "can count spaces in the list by how many have each contact status" do
    users_space_list.add_space(space_to_add_to_list)
    users_space_list.add_space(Fabricate(:space))

    expect(users_space_list.space_count).to eq(2)

    expect(users_space_list.space_not_contacted_count).to eq(2)
    expect(users_space_list.space_contacted_count).to eq(0)
    expect(users_space_list.space_said_no_count).to eq(0)
    expect(users_space_list.space_said_maybe_count).to eq(0)
    expect(users_space_list.space_said_yes_count).to eq(0)

    personal_data = users_space_list.this_lists_personal_data_on_spaces.find_by(space: space_to_add_to_list)
    personal_data.update(
      contact_status: "said_no"
    )

    users_space_list.reload
    expect(users_space_list.space_not_contacted_count).to eq(1)
    expect(users_space_list.space_contacted_count).to eq(1)
    expect(users_space_list.space_said_no_count).to eq(1)
    expect(users_space_list.space_said_maybe_count).to eq(0)
    expect(users_space_list.space_said_yes_count).to eq(0)

    personal_data.update(
      contact_status: "said_maybe"
    )

    users_space_list.reload
    expect(users_space_list.space_not_contacted_count).to eq(1)
    expect(users_space_list.space_contacted_count).to eq(1)
    expect(users_space_list.space_said_no_count).to eq(0)
    expect(users_space_list.space_said_maybe_count).to eq(1)
    expect(users_space_list.space_said_yes_count).to eq(0)

    personal_data.update(
      contact_status: "said_yes"
    )

    users_space_list.reload
    expect(users_space_list.space_not_contacted_count).to eq(1)
    expect(users_space_list.space_contacted_count).to eq(1)
    expect(users_space_list.space_said_no_count).to eq(0)
    expect(users_space_list.space_said_maybe_count).to eq(0)
    expect(users_space_list.space_said_yes_count).to eq(1)
  end

  it "only counts spaces in the list if they actually still are in the list" do
    users_space_list.add_space(space_to_add_to_list)
    users_space_list.add_space(Fabricate(:space))

    expect(users_space_list.space_count).to eq(2)
    expect(users_space_list.space_not_contacted_count).to eq(2)
    expect(users_space_list.space_contacted_count).to eq(0)
    expect(users_space_list.space_said_no_count).to eq(0)

    # Changing the contact_status of a space changes the counts:
    personal_data = users_space_list.this_lists_personal_data_on_spaces.find_by(space: space_to_add_to_list)
    personal_data.update(
      contact_status: "said_no"
    )

    users_space_list.reload
    expect(users_space_list.space_count).to eq(2)
    expect(users_space_list.space_not_contacted_count).to eq(1)
    expect(users_space_list.space_contacted_count).to eq(1)
    expect(users_space_list.space_said_no_count).to eq(1)

    # Removing the space changes the counts
    users_space_list.remove_space(space_to_add_to_list)

    users_space_list.reload
    expect(users_space_list.space_count).to eq(1)
    expect(users_space_list.space_not_contacted_count).to eq(1)
    expect(users_space_list.space_contacted_count).to eq(0)
    expect(users_space_list.space_said_no_count).to eq(0)

    # Re-adding the space remembers the state and count we had
    users_space_list.add_space(space_to_add_to_list)

    users_space_list.reload
    expect(users_space_list.space_count).to eq(2)
    expect(users_space_list.space_not_contacted_count).to eq(1)
    expect(users_space_list.space_contacted_count).to eq(1)
    expect(users_space_list.space_said_no_count).to eq(1)
  end
end

# == Schema Information
#
# Table name: personal_space_lists
#
#  id                        :bigint           not null, primary key
#  shared_with_public        :boolean          default(FALSE)
#  space_count               :integer          default(0)
#  space_not_contacted_count :integer          default(0)
#  space_said_maybe_count    :integer          default(0)
#  space_said_no_count       :integer          default(0)
#  space_said_yes_count      :integer          default(0)
#  title                     :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  user_id                   :bigint
#
# Indexes
#
#  index_personal_space_lists_on_user_id  (user_id)
#
