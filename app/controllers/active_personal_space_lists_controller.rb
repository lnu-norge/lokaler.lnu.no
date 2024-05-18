# frozen_string_literal: true

class ActivePersonalSpaceListsController < BaseControllers::AuthenticateController
  include AccessToPersonalSpaceListVerifiable
  before_action :set_personal_space_list, only: %i[activate deactivate]
  before_action :verify_that_user_has_access_to_personal_space_list

  def activate
    @personal_space_list.activate

    redirect_to personal_space_lists_url, notice: t("personal_space_lists.list_activated")
  end

  def deactivate
    @personal_space_list.deactivate

    redirect_to personal_space_lists_url, notice: t("personal_space_lists.list_deactivated")
  end

  private

  def set_personal_space_list
    @personal_space_list = PersonalSpaceList.find(params[:id])
  end
end
