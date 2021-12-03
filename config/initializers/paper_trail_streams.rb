# frozen_string_literal: true

# This extension to paper trail adds a after_create_commit hook,
# that will broadcast new Version objects to any listening clients.
module PaperTrail
  class Version < ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
    include PaperTrail::VersionConcern

    after_create_commit { broadcast_prepend_to "paper_trail_versions", partial: "admin/history/version" }
  end
end
