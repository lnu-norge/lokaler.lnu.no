# frozen_string_literal: true

module AccessToPersonalSpaceListVerifiable
  extend ActiveSupport::Concern

  private

  def verify_that_user_has_access_to_personal_space_list
    return unless params[:user_id]
    return if params[:user_id] == current_user.id
    return if current_user.admin?

    redirect_to personal_space_list_url, alert: t("personal_space_lists.no_access")
  end
end
