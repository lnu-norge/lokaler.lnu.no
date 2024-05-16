# frozen_string_literal: true

class SpaceInListController < BaseControllers::AuthenticateController
  before_action :require_space_in_list_params,
                :set_space,
                :set_list,
                :check_user_privileges

  include PersonalSpaceListsHelper

  def show; end

  def create
    return already_in_list if @list.spaces.include?(@space)

    @list.spaces << @space
    added_to_list
  end

  def destroy
    return not_in_list if @list.spaces.exclude?(@space)

    @list.spaces.delete(@space)
    removed_from_list
  end

  private

  def already_in_list
    flash_and_reload(message: t("personal_space_lists.space_not_in_list", space_title: @space.title,
                                                                          list_title: @list.title))
  end

  def not_in_list
    flash_and_reload(type: :alert,
                     message: t("personal_space_lists.space_not_in_list", space_title: @space.title,
                                                                          list_title: @list.title))
  end

  def added_to_list
    flash_and_reload(message: t("personal_space_lists.space_added_to_list", space_title: @space.title,
                                                                            list_title: @list.title))
  end

  def removed_from_list
    flash_and_reload(message: t("personal_space_lists.space_removed_from_list", space_title: @space.title,
                                                                                list_title: @list.title))
  end

  def flash_and_reload(
    message:, type: :notice,
    redirect_path: list_status_for_space_path(@list, @space)
  )
    respond_to do |format|
      format.turbo_stream do
        flash.now[type] = message
        render turbo_stream: [
          add_flash_with_turbo_stream,
          refresh_list_status_for_space_with_turbo_stream,
          refresh_active_list_with_turbo_stream
        ]
      end

      format.html do
        flash[type] = message
        redirect_to redirect_path
      end
    end
  end

  def add_flash_with_turbo_stream
    turbo_stream.prepend(
      "flash",
      partial: "shared/flash",
      locals: { flash: }
    )
  end

  def refresh_list_status_for_space_with_turbo_stream
    turbo_stream.update(
      dom_id_for_list_status_for_space(@space),
      partial: "space_in_list/list_status_for_space",
      locals: { list: @list, space: @space }
    )
  end

  def refresh_active_list_with_turbo_stream
    turbo_stream.update(
      dom_id_for_active_list_updates_here,
      partial: "personal_space_lists/personal_space_list",
      locals: { personal_space_list: @list }
    )
  end

  def require_space_in_list_params
    return unless params[:space_id].blank? || params[:personal_space_list_id].blank?

    flash[:alert] = t("personal_space_lists.need_to_choose_a_list_and_space")
    redirect_to personal_space_lists_path
  end

  def set_space
    @space = Space.find(params[:space_id])
  end

  def set_list
    if params[:personal_space_list_id] == "new"
      return @list = PersonalSpaceList.create_default_list_for(current_user,
                                                               active: true)
    end

    @list = PersonalSpaceList.find(params[:personal_space_list_id])
  end

  def check_user_privileges
    return if current_user.personal_space_lists.include?(@list)
    return if current_user.admin?

    flash[:alert] = t("personal_space_lists.no_access")
    redirect_to personal_space_lists_path
  end
end
