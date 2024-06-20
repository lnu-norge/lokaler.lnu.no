# frozen_string_literal: true

require "rails_helper"

RSpec.describe PersonalSpaceList, type: :model do
  let(:users_space_list) { Fabricate(:personal_space_list) }
  let(:user) { users_space_list.user }

  it "can generate a personal_space_list" do
    expect(users_space_list).to be_truthy
  end

  it "can destroy a list" do
    expect(users_space_list.destroy).to change(described_class, :count).by(-1)
  end

  it "can destroy a list, even if it has a space" do
    space = Fabricate(:space)
    users_space_list.add_space(space)
    users_space_list.reload
    expect(users_space_list.destroy).to change(described_class, :count).by(-1)
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
end
