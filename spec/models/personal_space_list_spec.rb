# frozen_string_literal: true

require "rails_helper"

RSpec.describe PersonalSpaceList, type: :model do
  let(:users_space_list) { Fabricate(:personal_space_list) }

  it "can generate a personal_space_list" do
    expect(users_space_list).to be_truthy
  end
end
