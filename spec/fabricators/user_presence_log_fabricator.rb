# frozen_string_literal: true

Fabricator(:user_presence_log) do
  user
  date { Date.current }
end

# == Schema Information
#
# Table name: user_presence_logs
#
#  id         :bigint           not null, primary key
#  date       :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_presence_logs_on_date              (date)
#  index_user_presence_logs_on_user_id           (user_id)
#  index_user_presence_logs_on_user_id_and_date  (user_id,date) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
