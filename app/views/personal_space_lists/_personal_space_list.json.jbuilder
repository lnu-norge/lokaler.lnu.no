# frozen_string_literal: true

json.extract! personal_space_list, :id, :user_id, :created_at, :updated_at
json.url personal_space_list_url(personal_space_list, format: :json)
