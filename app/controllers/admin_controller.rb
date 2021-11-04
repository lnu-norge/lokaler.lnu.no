# frozen_string_literal: true

class AdminController < AuthenticateController
  before_action :authenticate_admin!

  def index
    @current_page = params["page"].to_i || 1
    @current_page = 1 if @current_page < 1

    @versions = Kaminari.paginate_array(
      PaperTrail::Version.all.includes(:item).order(created_at: :desc)
    ).page(@current_page).per(50)
  end

  def show
    @space = Space.find(params["id"])

    @current_page = params["page"].to_i || 1
    @current_page = 1 if @current_page < 1

    @versions = @space.merge_paper_trail_versions.includes(:item).order(created_at: :desc)

    @versions = Kaminari.paginate_array(
      @versions
    ).page(@current_page).per(5)
  end

  def revert_changes
    result = PaperTrail::Version.find(params["id"])

    result.reify.save!

    redirect_to admin_index_path
  end

  protected

  def authenticate_admin!
    authenticate_user!
    redirect_to spaces_path unless current_user.admin?
  end
end
