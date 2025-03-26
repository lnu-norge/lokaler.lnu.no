# frozen_string_literal: true

module Users
  class SessionsController < Devise::Passwordless::SessionsController
    def create
      user = resource_class.find_or_create_by!(email: create_params[:email])
      unless user.persisted?
        set_flash_message!(:alert, :not_found_in_database, now: true)
        return render :new, status: devise_error_status
      end

      send_magic_link(user)
      set_flash_message!(:notice, :magic_link_sent)
      redirect_to(after_magic_link_sent_path_for(user), status: devise_redirect_status)
    end

    def after_magic_link_sent_path_for(_user)
      new_user_session_path
    end
  end
end
