# frozen_string_literal: true

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  # Log in with devise:
  devise_for :users,
             path: "",
             path_names: {
               sign_in: "logg_inn",
               sign_out: "logg_ut",
               edit: "rediger"
             },
             controllers: {
               magic_links: "users/magic_links",
               sessions: "users/sessions",
               registrations: "users/registrations",
               omniauth_callbacks: "users/omniauth_callbacks"
             }

  devise_scope :user do
    authenticated :user do
      root to: "spaces#index"
      get "session", to: "devise/sessions#edit", as: "edit_session"
    end
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
  get "/lokaler/mapbox_vector_tiles/:z/:x/:y", to: "spaces/map_vector#show", as: "space_map_vector"
  get "/lokaler/:space_id/map_marker", to: "spaces/map_marker#show", as: "map_marker"
  get "/lokaler/map_selected_geo_area", to: "spaces/map_selected_geo_area#show", as: "map_selected_geo_area"

  # Review routes
  resources "reviews", except: "new"
  get "/lokaler/:space_id/new_review", to: "reviews#new", as: "new_review"

  # Admin routes
  namespace "admin" do
    root to: "menu#index"
    resources :dashboard, only: [:index]
    resources "history", only: [:index, :show]
    post "history/revert_changes", to: "history#revert_changes"
    resources "space_types"
    resources "sync_statuses"
    resources "user_lists", only: [:index]
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end

  # Spaces routes
  resources "lokaler", controller: "spaces", as: "spaces", except: "new"
  get "/nytt-lokale/", to: "spaces#new", as: "new_space"
  get "/lokaler/:id/edit/:field", to: "spaces#edit_field", as: "edit_field"
  get "/lokaler/:id/images/:start", to: "spaces#fullscreen_images", as: "fullscreen_images"
  get "rect_for_spaces", to: "spaces#rect_for_spaces"
  get "address_search", to: "spaces#address_search"
  get "check_duplicates", to: "spaces#check_duplicates"

  # Personal space list routes
  resources :personal_space_lists, path: "lister" do
    member do # Member adds more paths to resources
      post "activate", to: "active_personal_space_lists#create", as: "activate_personal_space_list"
      post "deactivate", to: "active_personal_space_lists#destroy", as: "deactivate_personal_space_list"
    end
    scope module: "personal_space_lists" do
      resource :shared_with_public, only: [:show, :create, :destroy]
      resource :shared_with_me, only: [:show, :create, :destroy]
    end
    resources :spaces, path: "lokale" do
      scope module: "personal_space_lists" do
        member do
          get "space_in_list", to: "space_in_list#show", as: "status_for"
          post "space_in_list", to: "space_in_list#create", as: "add_to"
          delete "space_in_list", to: "space_in_list#destroy", as: "remove_from"
        end
        resources :personal_notes, only: [:edit, :update], path: "personlige_notater"
        resources :contact_status, only: [:edit, :update], path: "status"
      end
    end
  end

  # Space images routes
  resources "space_images"
  post "spaces/upload_image", to: "space_images#upload_image"

  if Rails.env.development?
    redirector = ->(params, _) { ApplicationController.helpers.asset_path("#{params[:name].split('-').first}.map") }
    constraint = ->(request) { request.path.ends_with?(".map") }
    get "assets/*name", to: redirect(redirector), constraints: constraint
  end

  get "up" => "rails/health#show", as: :rails_health_check

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
