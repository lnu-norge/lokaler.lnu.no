# frozen_string_literal: true

module PersonalSpaceLists
  class SharedWithMesController < BaseControllers::AuthenticateController
    before_action :set_personal_space_list

    def create
      @personal_space_list.add_to_shared_with_user(user: current_user)

      redirect_to personal_space_lists_path, notice: t("personal_space_lists.list_added")
    end

    def destroy
      @personal_space_list.remove_from_shared_with_user(user: current_user)

      redirect_to personal_space_lists_path, notice: t("personal_space_lists.list_removed")
    end

    private

    def set_personal_space_list
      @personal_space_list = PersonalSpaceList.find(params[:personal_space_list_id])

      redirect_with_error if @personal_space_list.nil?
    end

    def redirect_with_error
      redirect_to personal_space_lists_url, alert: t("generic_error")
    end
  end
end
