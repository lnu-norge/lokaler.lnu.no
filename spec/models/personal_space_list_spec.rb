# frozen_string_literal: true

require "rails_helper"

RSpec.describe PersonalSpaceList, type: :model do
  let(:users_space_list) { Fabricate(:personal_space_list) }

  it "can generate a personal_space_list" do
    expect(users_space_list).to be_truthy
  end

  it "onlies add spaces to the list once" do
    space = Fabricate(:space)
    users_space_list.spaces << space
    users_space_list.spaces << space
    expect(users_space_list.spaces.count).to eq(1)
  end
end
