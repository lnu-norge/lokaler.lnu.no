# frozen_string_literal: true

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  # Log in with devise:
  devise_for :users,
             path: "",
             path_names: {
               sign_in: "logg_inn",
               sign_out: "logg_ut",
               sign_up: "registrer_deg"
             },
             controllers: { registrations: "users/registrations", omniauth_callbacks: "users/omniauth_callbacks" }

  devise_scope :user do
    authenticated :user do
      root to: "spaces#index"
    end
  end

  # Devise addons
  devise_scope :user do
    get "session", to: "devise/sessions#edit", as: "edit_session"
  end

  # Homepage for unauthenticated users
  root to: "high_voltage/pages#show", id: "frontpage", as: "unauthenticated_root"

  # Resources
  resources "facilities", except: "new"
  resources "space_groups", except: "new"
  resources "space_contacts", only: [:create, :edit, :update, :destroy, :show]

  get "/lokaler/:space_id/facility_review/:facility_id/:facility_category_id", to: "facility_reviews#show",
                                                                               as: "facility_review"
  get "/lokaler/:space_id/facility_review/:facility_id/new/:facility_category_id/", to: "facility_reviews#new",
                                                                                    as: "new_facility_review"
  post "/lokaler/:space_id/facility_review/:facility_id", to: "facility_reviews#create", as: "create_facility_review"

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
  resources "lokaler", controller: "spaces", as: "spaces"
  get "/lokaler/:id/edit/:field", to: "spaces#edit_field", as: "edit_field"
  get "/lokaler/:id/images/:start", to: "spaces#fullscreen_images", as: "fullscreen_images"
  get "spaces_search", to: "spaces#spaces_search"
  get "rect_for_spaces", to: "spaces#rect_for_spaces"
  get "address_search", to: "spaces#address_search"
  get "check_duplicates", to: "spaces#check_duplicates"

  # Personal space list routes
  resources "lister", controller: "personal_space_lists", as: "personal_space_lists"
  post "lister/:id/activate", to: "active_personal_space_lists#activate", as: "activate_personal_space_list"
  post "lister/:id/deactivate", to: "active_personal_space_lists#deactivate", as: "deactivate_personal_space_list"
  get "space_in_list/:personal_space_list_id/:space_id", to: "space_in_list#show", as: "list_status_for_space"
  post "space_in_list/:personal_space_list_id/:space_id", to: "space_in_list#create", as: "add_space_to_list"
  delete "space_in_list/:personal_space_list_id/:space_id", to: "space_in_list#destroy", as: "remove_space_from_list"

  # Space images routes
  resources "space_images"
  post "spaces/upload_image", to: "space_images#upload_image"

  if Rails.env.development?
    redirector = ->(params, _) { ApplicationController.helpers.asset_path("#{params[:name].split('-').first}.map") }
    constraint = ->(request) { request.path.ends_with?(".map") }
    get "assets/*name", to: redirect(redirector), constraints: constraint
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
