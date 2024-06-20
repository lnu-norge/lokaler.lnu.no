# frozen_string_literal: true

module AccessToPersonalSpaceListVerifiable
  extend ActiveSupport::Concern

  private

  def verify_that_user_has_access_to_personal_space_list
    return no_access if @personal_space_list.blank?
    return if @personal_space_list&.user_id == current_user.id
    return set_as_shared_with_me if @personal_space_list&.shared_with_public?
    return if current_user.admin?

    no_access
  end

  def verify_that_user_is_owner_or_admin
    return no_access if @personal_space_list.blank?
    return if @personal_space_list&.user_id == current_user.id
    return if current_user.admin?

    no_access
  end

  def set_as_shared_with_me
    return if @personal_space_list.already_shared_with_user(user: current_user)

    @personal_space_list.add_to_shared_with_user(user: current_user)
    flash.now[:notice] = t("personal_space_lists.list_added")
  end

  def no_access
    redirect_to personal_space_lists_url, alert: t("personal_space_lists.no_access")
  end
end
