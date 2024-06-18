# frozen_string_literal: true

module PersonalSpaceLists
  class SharedWithPublicsController < BaseControllers::AuthenticateController
    before_action :set_personal_space_list, :check_that_user_has_access
    def edit; end

    def update
      @personal_space_list.update(allowed_params)
      render :edit
    end

    private

    def allowed_params
      params.require(:personal_space_list).permit(:shared_with_public)
    end

    def set_personal_space_list
      @personal_space_list = PersonalSpaceList.find(params[:personal_space_list_id])

      redirect_with_error if @personal_space_list.nil?
    end

    def check_that_user_has_access
      return if @personal_space_list.user == current_user
      return if current_user.admin?

      redirect_to personal_space_lists_url, alert: t("personal_space_lists.no_access")
    end

    def redirect_with_error
      redirect_to personal_space_lists_url, alert: t("generic_error")
    end
  end
end
