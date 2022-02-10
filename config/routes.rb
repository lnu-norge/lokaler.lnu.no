# frozen_string_literal: true

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  devise_for :users,
             path: "",
             path_names: {
               sign_in: "signin",
               sign_out: "signout",
               sign_up: "signup"
             },
             controllers: { registrations: "users/registrations", omniauth_callbacks: "users/omniauth_callbacks" }

  devise_scope :user do
    authenticated :user do
      root to: "spaces#index"
    end
  end

  root to: "high_voltage/pages#show", id: "frontpage", as: "unauthenticated_root"

  # Resources
  resources "facilities", except: "new"
  resources "space_groups", except: "new"
  resources "space_contacts", only: [:create, :edit, :update, :destroy, :show]

  get "/facility_reviews/:space_id/new", to: "facility_reviews#new", as: "new_facility_review"
  post "/facility_reviews/:space_id", to: "facility_reviews#create", as: "create_facility_review"

  # Review routes
  resources "reviews", except: "new"
  get "/spaces/:space_id/new_review", to: "reviews#new", as: "new_review"

  # Admin routes
  namespace "admin" do
    root to: "dashboard#index"
    resources "history"
    resources "space_types"
    post "history/revert_changes", to: "history#revert_changes"
  end

  # Spaces routes
  resources "spaces"
  get "/spaces/:id/edit/:field", to: "spaces#edit_field", as: "edit_field"
  get "spaces_search", to: "spaces#spaces_search"
  get "rect_for_spaces", to: "spaces#rect_for_spaces"
  get "address_search", to: "spaces#address_search"
  get "check_duplicates", to: "spaces#check_duplicates"
  get "/spaces/:id/images/:start", to: "spaces#fullscreen_images", as: "fullscreen_images"

  # Space images routes
  resources "space_images"
  post "spaces/upload_image", to: "space_images#upload_image"

  # Devise addons
  devise_scope :user do
    get "session", to: "devise/sessions#edit", as: "edit_session"
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
