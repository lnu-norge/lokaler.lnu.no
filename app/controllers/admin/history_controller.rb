# frozen_string_literal: true

module Admin
  class HistoryController < Admin::AdminController
    MAX_PAGE_SIZE = 5

    def paginate_array(array)
      @current_page = params["page"].to_i || 1
      @current_page = 1 if @current_page < 1

      @versions = Kaminari.paginate_array(
        array
      ).page(@current_page).per(MAX_PAGE_SIZE)

      @last_page = true if @versions.size < MAX_PAGE_SIZE
    end

    def index
      paginate_array(PaperTrail::Version.all.includes(:item).order(created_at: :desc))
    end

    def show
      @space = Space.find(params["id"])

      paginate_array(@space.merge_paper_trail_versions.includes(:item).order(created_at: :desc))
    end

    def revert_changes
      result = PaperTrail::Version.find(params["id"])

      result.reify.save!

      redirect_to admin_index_path
    end
  end
end
