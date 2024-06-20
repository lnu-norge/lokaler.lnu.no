# frozen_string_literal: true

require "rails_helper"

RSpec.describe PersonalSpaceLists::SharedWithPublicsController, type: :request do
  let(:user) { Fabricate(:user) }
  let(:space) { Fabricate(:space) }
  let(:users_space_list) { Fabricate(:personal_space_list, user:) }
  let(:someone_elses_space_list) { Fabricate(:personal_space_list) }

  before do
    sign_in user
  end

  it "can share a list, and stop sharing it" do
    expect(users_space_list.shared_with_public).to be(false)

    post personal_space_list_shared_with_public_path(personal_space_list_id: users_space_list)
    expect(response).to have_http_status(:ok)

    users_space_list.reload
    expect(users_space_list.shared_with_public).to be(true)

    delete personal_space_list_shared_with_public_path(personal_space_list_id: users_space_list)
    expect(response).to have_http_status(:ok)

    users_space_list.reload
    expect(users_space_list.shared_with_public).to be(false)
  end

  it "can only share your own list" do
    expect(someone_elses_space_list.shared_with_public).to be(false)

    post personal_space_list_shared_with_public_path(personal_space_list_id: someone_elses_space_list)
    expect(response).to redirect_to(personal_space_lists_path)

    expect(someone_elses_space_list.shared_with_public).to be(false)
  end

  it "can only access someone elses list if it is shared" do
    get personal_space_list_path(someone_elses_space_list)
    expect(response).to redirect_to(personal_space_lists_path)
    expect(user.personal_space_lists_shared_with_mes.count).to eq(0)

    someone_elses_space_list.start_sharing

    get personal_space_list_path(someone_elses_space_list)
    expect(response).to have_http_status(:ok)
    # Check that its added to lists shared with me
    expect(user.personal_space_lists_shared_with_mes.first.personal_space_list_id).to eq(someone_elses_space_list.id)

    someone_elses_space_list.stop_sharing

    get personal_space_list_path(someone_elses_space_list)
    expect(response).to redirect_to(personal_space_lists_path)
    # Check that its removed from lists shared with me
    expect(user.personal_space_lists_shared_with_mes.reload.count).to eq(0)
  end

  it "can add and remove spaces in someone elses shared list, but only when shared" do
    post add_to_personal_space_list_space_path(personal_space_list_id: someone_elses_space_list.id, id: space.id)
    expect(someone_elses_space_list.reload.spaces.count).to eq(0)

    someone_elses_space_list.start_sharing

    post add_to_personal_space_list_space_path(personal_space_list_id: someone_elses_space_list.id, id: space.id)
    expect(someone_elses_space_list.reload.spaces.count).to eq(1)

    delete remove_from_personal_space_list_space_path(personal_space_list_id: someone_elses_space_list.id, id: space.id)
    expect(someone_elses_space_list.reload.spaces.count).to eq(0)

    someone_elses_space_list.stop_sharing

    post add_to_personal_space_list_space_path(personal_space_list_id: someone_elses_space_list.id, id: space.id)
    expect(someone_elses_space_list.reload.spaces.count).to eq(0)
  end

  it "can change contact status and personal_notes for spaces in someone elses shared list, but only when shared" do
    someone_elses_space_list.add_space(space)
    someone_elses_data_on_space = someone_elses_space_list.this_lists_personal_data_on_spaces.find_by(space:)

    put personal_space_list_space_personal_note_path(
      personal_space_list_id: someone_elses_space_list.id,
      space_id: space.id,
      id: "irrelevant"
    ), params: {
      personal_data_on_space_in_list: {
        personal_notes: "My text in your list"
      }
    }
    expect(response).to redirect_to(personal_space_lists_path)
    expect(someone_elses_data_on_space.reload.personal_notes).to be_nil

    put personal_space_list_space_contact_status_path(
      personal_space_list_id: someone_elses_space_list.id,
      space_id: space.id,
      id: "irrelevant"
    ), params: {
      personal_data_on_space_in_list: {
        contact_status: "said_no"
      }
    }
    expect(response).to redirect_to(personal_space_lists_path)
    expect(someone_elses_data_on_space.reload.contact_status).to eq("not_contacted")

    someone_elses_space_list.start_sharing

    put personal_space_list_space_personal_note_path(
      personal_space_list_id: someone_elses_space_list.id,
      space_id: space.id,
      id: "irrelevant"
    ), params: {
      personal_data_on_space_in_list: {
        personal_notes: "My text in your list"
      }
    }
    expect(response).to have_http_status(:ok)
    expect(someone_elses_data_on_space.reload.personal_notes).to eq("My text in your list")

    put personal_space_list_space_contact_status_path(
      personal_space_list_id: someone_elses_space_list.id,
      space_id: space.id,
      id: "irrelevant"
    ), params: {
      personal_data_on_space_in_list: {
        contact_status: "said_no"
      }
    }
    expect(response).to have_http_status(:ok)
    expect(someone_elses_data_on_space.reload.contact_status).to eq("said_no")

    someone_elses_space_list.stop_sharing

    put personal_space_list_space_contact_status_path(
      personal_space_list_id: someone_elses_space_list.id,
      space_id: space.id,
      id: "irrelevant"
    ), params: {
      personal_data_on_space_in_list: {
        contact_status: "said_yes"
      }
    }
    expect(response).to redirect_to(personal_space_lists_path)
    expect(someone_elses_data_on_space.reload.contact_status).to eq("said_no")
  end

  it "can activate and deactivate a list shared by someone, and have it removed if the list is no longer shared" do
    expect(user.active_personal_space_list).to be_nil

    post activate_personal_space_list_personal_space_list_path(id: someone_elses_space_list.id)
    expect(user.reload.active_personal_space_list).to be_nil

    someone_elses_space_list.start_sharing

    post activate_personal_space_list_personal_space_list_path(id: someone_elses_space_list.id)
    expect(user.reload.active_personal_space_list.personal_space_list_id).to be(someone_elses_space_list.id)

    post deactivate_personal_space_list_personal_space_list_path(id: someone_elses_space_list.id)
    expect(user.reload.active_personal_space_list).to be_nil

    post activate_personal_space_list_personal_space_list_path(id: someone_elses_space_list.id)
    expect(user.reload.active_personal_space_list.personal_space_list_id).to be(someone_elses_space_list.id)

    someone_elses_space_list.stop_sharing
    expect(user.reload.active_personal_space_list).to be_nil
  end
end
