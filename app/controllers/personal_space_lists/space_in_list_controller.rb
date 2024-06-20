# frozen_string_literal: true

module PersonalSpaceLists
  class SpaceInListController < BaseControllers::AuthenticateController
    before_action :require_space_in_list_params,
                  :set_space,
                  :set_list,
                  :verify_that_user_has_access_to_personal_space_list

    include PersonalSpaceListsHelper
    include SettableFilteredFacilities
    include AccessToPersonalSpaceListVerifiable

    def show; end

    def create
      return already_in_list if @personal_space_list.includes_space?(@space)

      @personal_space_list.add_space(@space)
      added_to_list
    end

    def destroy
      return not_in_list if @personal_space_list.excludes_space?(@space)

      @personal_space_list.remove_space(@space)
      removed_from_list
    end

    private

    def already_in_list
      flash_and_reload(message: t("personal_space_lists.space_already_in_list", space_title: @space.title))
    end

    def not_in_list
      flash_and_reload(type: :alert,
                       message: t("personal_space_lists.space_not_in_list", space_title: @space.title))
    end

    def added_to_list
      flash_and_reload(message: t("personal_space_lists.space_added_to_list", space_title: @space.title))
    end

    def removed_from_list
      flash_and_reload(message: t("personal_space_lists.space_removed_from_list", space_title: @space.title))
    end

    def flash_and_reload(
      message:, type: :notice,
      redirect_path: status_for_personal_space_list_space_path(@personal_space_list, @space)
    )
      set_filtered_facilities
      respond_to do |format|
        format.turbo_stream do
          render partial: "personal_space_lists/space_in_list/turbo_stream_updates_when_list_status_changes",
                 locals: {
                   personal_space_list: @personal_space_list,
                   space: @space,
                   personal_data_on_space_in_list: find_personal_data_on_space_in_list,
                   update_status_of_all_spaces_in_list: creating_new_list?
                 }
        end

        format.html do
          flash[type] = message
          redirect_to redirect_path
        end
      end
    end

    def require_space_in_list_params
      return unless params[:id].blank? || params[:personal_space_list_id].blank?

      flash_and_reload(
        type: :alert,
        message: t("personal_space_lists.need_to_choose_a_list_and_space"),
        redirect_path: personal_space_lists_path
      )
    end

    def find_personal_data_on_space_in_list
      return unless @space.present? && @personal_space_list.present?

      @personal_space_list.personal_data_on_space_in_lists.find_by(space: @space)
    end

    def set_space
      @space = Space.find(params[:id])
    end

    def creating_new_list?
      params[:personal_space_list_id] == "new"
    end

    def set_list
      if creating_new_list?
        return @personal_space_list = PersonalSpaceList.create_default_list_for(current_user,
                                                                                active: true)
      end

      @personal_space_list = PersonalSpaceList.find(params[:personal_space_list_id])
    end
  end
end
