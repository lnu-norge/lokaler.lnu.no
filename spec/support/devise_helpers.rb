# frozen_string_literal: true

module DeviseHelpers
  def fill_in_email(email)
    fill_in I18n.t("devise.registrations.user.email"), with: email
  end

  def click_reset_password_button
    click_on I18n.t("simple_form.labels.user.password_reset")
  end

  def fill_in_password(password)
    fill_in I18n.t("simple_form.labels.user.password"), with: password
  end

  def fill_in_password_confirmation(password)
    fill_in I18n.t("simple_form.labels.user.password_confirmation"), with: password
  end

  def click_change_password_button
    click_on I18n.t("simple_form.labels.user.change_password")
  end

  def fill_in_and_ask_for_new_password
    fill_in_password "p4ssw0rd"
    fill_in_password_confirmation "p4ssw0rd"
    click_change_password_button
  end

  def click_login_button
    click_on I18n.t("simple_form.labels.user.submit_login")
  end
end
