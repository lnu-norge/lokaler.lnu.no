# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users,
             path: '',
             path_names: {
               sign_in: 'signin',
               sign_out: 'signout',
               sign_up: 'signup'
             }

  devise_scope :user do
    authenticated :user do
      root to: 'spaces#index'
    end
  end

  root to: 'devise/sessions#new', as: 'unauthenticated_root'

  resources 'facilities'
  resources 'spaces'
  resources 'organizations'
  resources 'reviews'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
