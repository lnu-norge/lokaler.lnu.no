# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActivePersonalSpaceList, type: :request do
  let(:user) { Fabricate(:user) }
  let(:users_space_list) { Fabricate(:personal_space_list, user:) }
  let(:someone_elses_space_list) { Fabricate(:personal_space_list) }

  before do
    sign_in user
  end

  it "can activate and deactivate a list" do
    expect(user.active_personal_space_list).to be_nil

    post activate_personal_space_list_personal_space_list_path(id: users_space_list.id)
    expect(user.reload.active_personal_space_list.personal_space_list_id).to be(users_space_list.id)

    post deactivate_personal_space_list_personal_space_list_path(id: users_space_list.id)
    expect(user.reload.active_personal_space_list).to be_nil
  end
end
