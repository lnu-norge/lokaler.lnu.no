# frozen_string_literal: true

require "rails_helper"

RSpec.describe PersonalSpaceList, type: :request do
  let(:user) { Fabricate(:user) }
  let(:users_space_list) { Fabricate(:personal_space_list, user:) }
  let(:someone_elses_space_list) { Fabricate(:personal_space_list) }

  before do
    sign_in user
  end

  it "redirects if not logged in" do
    sign_out user
    get new_personal_space_list_path
    expect(response).to have_http_status(:redirect)
    expect(response).to redirect_to(new_user_session_path)
  end

  it "loads your own lists" do
    get personal_space_lists_path
    expect(response).to have_http_status(:success)
  end

  it "redirects to your own lists if you try to access someone elses" do
    get personal_space_list_path(someone_elses_space_list)
    expect(response).to have_http_status(:redirect)
    expect(response).to redirect_to(personal_space_lists_path)
  end

  it "can create a new list" do
    title = "My new list"
    expect(user.personal_space_lists.count).to eq(1)
    post personal_space_lists_path, params: {
      personal_space_list: {
        user_id: user.id,
        title:
      }
    }
    follow_redirect!
    expect(response).to have_http_status(:success)
    expect(response.body).to match title
    expect(user.personal_space_lists.count).to eq(2)
  end

  it "can edit a list" do
    new_title = "Fancy new title"
    patch personal_space_list_path(users_space_list), params: {
      personal_space_list: {
        title: new_title
      }
    }
    follow_redirect!
    expect(response).to have_http_status(:success)
    expect(response.body).to match new_title
  end

  it "can destroy a list" do
    delete personal_space_list_path(users_space_list)
    follow_redirect!
    expect(response).to have_http_status(:success)
    expect(user.personal_space_lists.count).to eq(0)
  end
end
