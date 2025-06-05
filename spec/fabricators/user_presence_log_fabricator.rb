# frozen_string_literal: true

Fabricator(:user_presence_log) do
  user
  date { Date.current }
end
