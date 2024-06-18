# frozen_string_literal: true

class ActivePersonalSpaceListsController < BaseControllers::AuthenticateController
  include AccessToPersonalSpaceListVerifiable
  before_action :set_personal_space_list
  before_action :verify_that_user_has_access_to_personal_space_list

  def create
    @personal_space_list.activate_for(user: current_user)

    redirect_to personal_space_lists_url, notice: t("personal_space_lists.list_activated",
                                                    name: @personal_space_list.title)
  end

  def destroy
    @personal_space_list.deactivate_for(user: current_user)

    redirect_to personal_space_lists_url, notice: t("personal_space_lists.list_deactivated",
                                                    name: @personal_space_list.title)
  end

  private

  def set_personal_space_list
    @personal_space_list = PersonalSpaceList.find(params[:id])
  end
end
