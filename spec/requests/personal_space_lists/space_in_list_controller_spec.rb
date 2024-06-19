# frozen_string_literal: true

require "rails_helper"

RSpec.describe PersonalSpaceLists::SpaceInListController, type: :request do
  let(:user) { Fabricate(:user) }
  let(:users_space_list) { Fabricate(:personal_space_list, user:) }
  let(:someone_elses_space_list) { Fabricate(:personal_space_list) }

  before do
    sign_in user
  end

  it "can add spaces to a list" do
    space = Fabricate(:space)
    expect(users_space_list.spaces.count).to eq(0)
    post add_to_personal_space_list_space_path(personal_space_list_id: users_space_list.id, id: space.id)
    follow_redirect!
    expect(response).to have_http_status(:success)
    expect(users_space_list.spaces.count).to eq(1)
  end

  it "can remove spaces from a list" do
    space = Fabricate(:space)
    users_space_list.spaces << space
    expect(users_space_list.spaces.count).to eq(1)
    delete remove_from_personal_space_list_space_path(personal_space_list_id: users_space_list.id, id: space.id)
    follow_redirect!
    expect(response).to have_http_status(:success)
    expect(users_space_list.spaces.count).to eq(0)
  end

  it "can't add spaces to someone else's list" do
    space = Fabricate(:space)
    expect(someone_elses_space_list.spaces.count).to eq(0)
    post add_to_personal_space_list_space_path(personal_space_list_id: someone_elses_space_list.id, id: space.id)
    expect(response).to have_http_status(:redirect)
    expect(response).to redirect_to(personal_space_lists_path)
    expect(someone_elses_space_list.spaces.count).to eq(0)
  end

  it "can't remove spaces from someone else's list" do
    space = Fabricate(:space)
    someone_elses_space_list.spaces << space
    expect(someone_elses_space_list.spaces.count).to eq(1)
    delete remove_from_personal_space_list_space_path(personal_space_list_id: someone_elses_space_list.id,
                                                      id: space.id)
    expect(response).to have_http_status(:redirect)
    expect(response).to redirect_to(personal_space_lists_path)
    expect(someone_elses_space_list.spaces.count).to eq(1)
  end
end
