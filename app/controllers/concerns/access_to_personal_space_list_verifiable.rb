# frozen_string_literal: true

module AccessToPersonalSpaceListVerifiable
  extend ActiveSupport::Concern

  private

  def verify_that_user_has_access_to_personal_space_list
    return no_access if @personal_space_list.blank?
    return if @personal_space_list&.shared_with_public?
    return if @personal_space_list&.user_id == current_user.id
    return if current_user.admin?

    no_access
  end

  def no_access
    redirect_to personal_space_lists_url, alert: t("personal_space_lists.no_access")
  end
end
