# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'devise/passwords/new', type: :view do
  it 'renders the forgotten password form' do
    render 'devise/passwords/new', locals: { resource_name: :resource_name }

    # assert_select 'form[action=?][method=?]', user_password_path(resource_name), 'patch' do
    #   assert_select 'input[email=?]', 'user[email]'
    # end
  end
end
