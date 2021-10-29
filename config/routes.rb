# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users,
             path: "",
             path_names: {
               sign_in: "signin",
               sign_out: "signout",
               sign_up: "signup"
             }

  devise_scope :user do
    authenticated :user do
      root to: "spaces#index"
    end
  end

  root to: "devise/sessions#new", as: "unauthenticated_root"

  # Resources
  resources "facilities", except: "new"
  resources "space_owners", except: "new"

  # Review routes
  resources 'reviews', except: 'new'
  get '/spaces/:space_id/new_review', to: 'reviews#new', as: 'new_review'
  get '/spaces/:space_id/new_review/only_contacted', to: 'reviews#new_only_contacted', as: 'new_review_only_contacted'
  get '/spaces/:space_id/new_review/been_there', to: 'reviews#new_been_there', as: 'new_review_been_there'
  get '/spaces/:space_id/new_review/not_allowed_to_use', to: 'reviews#new_not_allowed_to_use',
                                                         as: 'new_review_not_allowed_to_use'

  # Admin routes
  resources "admin"
  post "admin/revert_changes", to: "admin#revert_changes"

  # Spaces routes
  resources "spaces", except: "new"
  get "/spaces/:id/edit/:field", to: "spaces#edit_field", as: "edit_field"
  get "spaces_search", to: "spaces#spaces_search"
  get "rect_for_spaces", to: "spaces#rect_for_spaces"
  get "address_search", to: "spaces#address_search"
  post "spaces/upload_image", to: "spaces#upload_image"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
