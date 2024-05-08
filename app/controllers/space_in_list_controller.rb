# frozen_string_literal: true

class SpaceInListController < BaseControllers::AuthenticateController
  before_action :require_space_in_list_params,
                :set_space,
                :set_list,
                :check_user_privileges

  def create
    if @list.spaces.include?(@space)
      flash[:notice] = t("personal_space_lists.space_already_in_list", space_name: @space.name, list_title: @list.title)
      return redirect_to personal_space_list_path(@list)
    end

    @list.spaces << @space
    flash[:notice] = t("personal_space_lists.space_added_to_list", space_name: @space.name, list_title: @list.title)
    redirect_to personal_space_list_path(@list)
  end

  def destroy
    if @list.spaces.exclude?(@space)
      flash[:notice] = t("personal_space_lists.space_not_in_list", space_name: @space.name, list_title: @list.title)
      return redirect_to personal_space_list_path(@list)
    end

    @list.spaces.delete(@space)
    flash[:notice] = t("personal_space_lists.space_removed_from_list", space_name: @space.name, list_title: @list.title)
    redirect_to personal_space_list_path(@list)
  end

  private

  def require_space_in_list_params
    return unless params[:space_id].blank? || params[:personal_space_list_id].blank?

    flash[:alert] = t("personal_space_lists.need_to_choose_a_list_and_space")
    redirect_to personal_space_lists_path
  end

  def set_space
    @space = Space.find(params[:space_id])
  end

  def set_list
    @list = PersonalSpaceList.find(params[:personal_space_list_id])
  end

  def check_user_privileges
    return if current_user.personal_space_lists.include?(@list)
    return if current_user.admin?

    flash[:alert] = t("personal_space_lists.no_access")
    redirect_to personal_space_lists_path
  end
end
