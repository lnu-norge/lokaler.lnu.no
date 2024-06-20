# frozen_string_literal: true

require "rails_helper"

RSpec.describe PersonalSpaceLists::ContactStatusController, type: :request do
  let(:user) { Fabricate(:user) }
  let(:space_added_to_list) { Fabricate(:space) }
  let(:space_added_to_and_removed_from_list) { Fabricate(:space) }
  let(:personal_space_list) { Fabricate(:personal_space_list, user:) }

  before do
    sign_in user
    personal_space_list.add_space(space_added_to_list)
  end

  it "can render the form" do
    get edit_personal_space_list_space_contact_status_path(
      personal_space_list_id: personal_space_list.id,
      space_id: space_added_to_list.id,
      id: "irrelevant"
    )
    expect(response).to have_http_status(:success)
  end

  it "can add and edit a contact status about a space in the list" do
    personal_data = personal_space_list.personal_data_on_space_in_lists.find_or_create_by(space: space_added_to_list)

    expect(personal_data.contact_status).to eq("not_contacted")

    new_status = "said_no"

    put personal_space_list_space_contact_status_path(
      personal_space_list_id: personal_space_list.id,
      space_id: space_added_to_list.id,
      id: "irrelevant"
    ), params: {
      personal_data_on_space_in_list: {
        contact_status: new_status
      }
    }
    expect(response).to have_http_status(:success)
    expect(personal_data.reload.contact_status).to eq(new_status)
  end
end
