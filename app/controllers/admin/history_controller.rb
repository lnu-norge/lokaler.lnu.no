# frozen_string_literal: true

module Admin
  class HistoryController < BaseControllers::AuthenticateAsAdminController
    def index
      ActionView::Base.prefix_partial_path_with_controller_namespace = false
      @versions = PaperTrail::Version.includes(:item).order(created_at: :desc).limit(10)
    end

    def show
      @space = Space.find(params["id"])

      @space.merge_paper_trail_versions.includes(:item).order(created_at: :desc)
    end

    def revert_changes
      result = PaperTrail::Version.find(params["id"])

      result.reify.save!

      redirect_to admin_index_path
    end
  end
end
