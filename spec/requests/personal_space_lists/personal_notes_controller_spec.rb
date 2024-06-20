# frozen_string_literal: true

require "rails_helper"

RSpec.describe PersonalSpaceLists::PersonalNotesController, type: :request do
  let(:user) { Fabricate(:user) }
  let(:space_added_to_list) { Fabricate(:space) }
  let(:space_added_to_and_removed_from_list) { Fabricate(:space) }
  let(:personal_space_list) { Fabricate(:personal_space_list, user:) }

  before do
    sign_in user
    personal_space_list.add_space(space_added_to_list)
  end

  it "can render the form" do
    get edit_personal_space_list_space_personal_note_path(
      personal_space_list_id: personal_space_list.id,
      space_id: space_added_to_list.id,
      id: "irrelevant"
    )
    expect(response).to have_http_status(:success)
  end

  it "can add and edit a personal note about a space in the list" do
    first_note_text = "Shiny note!"

    put personal_space_list_space_personal_note_path(
      personal_space_list_id: personal_space_list.id,
      space_id: space_added_to_list.id,
      id: "irrelevant"
    ), params: {
      personal_data_on_space_in_list: {
        personal_notes: first_note_text
      }
    }
    expect(response).to have_http_status(:success)

    personal_data = personal_space_list.personal_data_on_space_in_lists.find_by(space: space_added_to_list)
    expect(personal_data.reload.personal_notes).to eq(first_note_text)

    new_note_text = "New note is newer"

    put personal_space_list_space_personal_note_path(
      personal_space_list_id: personal_space_list.id,
      space_id: space_added_to_list.id,
      id: "irrelevant"
    ), params: {
      personal_data_on_space_in_list: {
        personal_notes: new_note_text
      }
    }

    expect(response).to have_http_status(:success)
    expect(personal_data.reload.personal_notes).to eq(new_note_text)

    empty_note_text = ""

    put personal_space_list_space_personal_note_path(
      personal_space_list_id: personal_space_list.id,
      space_id: space_added_to_list.id,
      id: "irrelevant"
    ), params: {
      personal_data_on_space_in_list: {
        personal_notes: empty_note_text
      }
    }

    expect(response).to have_http_status(:success)
    expect(personal_data.reload.personal_notes).to eq(empty_note_text)
  end
end
