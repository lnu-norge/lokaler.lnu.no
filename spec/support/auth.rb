# frozen_string_literal: true

module Auth
  def create_user!
    @user = Fabricate(:user)
  end

  def sign_in_user!
    setup_devise_mapping!
    sign_in @user
  end

  def sign_out_user!
    setup_devise_mapping!
    sign_out @user
  end

  def setup_devise_mapping!
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  def login_with_warden!
    login_as(@user, scope: :user)
  end

  def logout_with_warden!
    logout(:user)
  end

  def login_and_logout_with_devise
    sign_in_user!
    yield
    sign_out_user!
  end

  def login_and_logout_with_warden
    Warden.test_mode!
    login_with_warden!
    yield
    logout_with_warden!
    Warden.test_reset!
  end
end
