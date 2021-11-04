# frozen_string_literal: true

module PaperTrail
  class Version < ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
    include PaperTrail::VersionConcern

    after_create_commit { broadcast_prepend_to "paper_trail_versions", partial: "admin/version" }
  end
end
