# frozen_string_literal: true

class AdminController < AuthenticateController
  before_action :authenticate_admin!

  def index; end

  def show
    @space = Space.find(params['id'])

    @current_page = params['page'].to_i || 1
    @current_page = 1 if @current_page < 1

    @versions = @space.merge_paper_trail_versions

    # Merge all the versions into one list
    # this may be a slow if there is a large amount of versions
    @versions = Kaminari.paginate_array(
      @versions
    ).page(@current_page).per(5)
  end

  def revert_changes
    result = PaperTrail::Version.find(params['id'])

    result.reify.save!

    redirect_to admin_path(params[:space_id])
  end

  protected

  def authenticate_admin!
    authenticate_user!
    redirect_to spaces_path unless current_user.admin?
  end
end
