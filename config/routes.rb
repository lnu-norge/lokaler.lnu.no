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

# == Route Map
#
#                                             Prefix Verb     URI Pattern                                                                                       Controller#Action
#              user_google_oauth2_omniauth_authorize GET|POST /auth/google_oauth2(.:format)                                                                     users/omniauth_callbacks#passthru
#               user_google_oauth2_omniauth_callback GET|POST /auth/google_oauth2/callback(.:format)                                                            users/omniauth_callbacks#google_oauth2
#                           cancel_user_registration GET      /cancel(.:format)                                                                                 users/registrations#cancel
#                              new_user_registration GET      /sign_up(.:format)                                                                                users/registrations#new
#                             edit_user_registration GET      /rediger(.:format)                                                                                users/registrations#edit
#                                  user_registration PATCH    /                                                                                                 users/registrations#update
#                                                    PUT      /                                                                                                 users/registrations#update
#                                                    DELETE   /                                                                                                 users/registrations#destroy
#                                                    POST     /                                                                                                 users/registrations#create
#                                    user_magic_link GET      /magic_link(.:format)                                                                             users/magic_links#show
#                                   new_user_session GET      /logg_inn(.:format)                                                                               users/sessions#new
#                                       user_session POST     /logg_inn(.:format)                                                                               users/sessions#create
#                               destroy_user_session DELETE   /logg_ut(.:format)                                                                                users/sessions#destroy
#                                               root GET      /                                                                                                 spaces#index
#                                       edit_session GET      /session(.:format)                                                                                devise/sessions#edit
#                               unauthenticated_root GET      /                                                                                                 high_voltage/pages#show {id: "frontpage"}
#                                         facilities GET      /facilities(.:format)                                                                             facilities#index
#                                                    POST     /facilities(.:format)                                                                             facilities#create
#                                      edit_facility GET      /facilities/:id/edit(.:format)                                                                    facilities#edit
#                                           facility GET      /facilities/:id(.:format)                                                                         facilities#show
#                                                    PATCH    /facilities/:id(.:format)                                                                         facilities#update
#                                                    PUT      /facilities/:id(.:format)                                                                         facilities#update
#                                                    DELETE   /facilities/:id(.:format)                                                                         facilities#destroy
#                                       space_groups GET      /space_groups(.:format)                                                                           space_groups#index
#                                                    POST     /space_groups(.:format)                                                                           space_groups#create
#                                   edit_space_group GET      /space_groups/:id/edit(.:format)                                                                  space_groups#edit
#                                        space_group GET      /space_groups/:id(.:format)                                                                       space_groups#show
#                                                    PATCH    /space_groups/:id(.:format)                                                                       space_groups#update
#                                                    PUT      /space_groups/:id(.:format)                                                                       space_groups#update
#                                                    DELETE   /space_groups/:id(.:format)                                                                       space_groups#destroy
#                                     space_contacts POST     /space_contacts(.:format)                                                                         space_contacts#create
#                                 edit_space_contact GET      /space_contacts/:id/edit(.:format)                                                                space_contacts#edit
#                                      space_contact GET      /space_contacts/:id(.:format)                                                                     space_contacts#show
#                                                    PATCH    /space_contacts/:id(.:format)                                                                     space_contacts#update
#                                                    PUT      /space_contacts/:id(.:format)                                                                     space_contacts#update
#                                                    DELETE   /space_contacts/:id(.:format)                                                                     space_contacts#destroy
#                                    facility_review GET      /lokaler/:space_id/facility_review/:facility_id/:facility_category_id(.:format)                   facility_reviews#show
#                                new_facility_review GET      /lokaler/:space_id/facility_review/:facility_id/new/:facility_category_id(.:format)               facility_reviews#new
#                             create_facility_review POST     /lokaler/:space_id/facility_review/:facility_id(.:format)                                         facility_reviews#create
#                                   space_map_vector GET      /lokaler/mapbox_vector_tiles/:z/:x/:y(.:format)                                                   spaces/map_vector#show
#                                         map_marker GET      /lokaler/:space_id/map_marker(.:format)                                                           spaces/map_marker#show
#                              map_selected_geo_area GET      /lokaler/map_selected_geo_area(.:format)                                                          spaces/map_selected_geo_area#show
#                                            reviews GET      /reviews(.:format)                                                                                reviews#index
#                                                    POST     /reviews(.:format)                                                                                reviews#create
#                                        edit_review GET      /reviews/:id/edit(.:format)                                                                       reviews#edit
#                                             review GET      /reviews/:id(.:format)                                                                            reviews#show
#                                                    PATCH    /reviews/:id(.:format)                                                                            reviews#update
#                                                    PUT      /reviews/:id(.:format)                                                                            reviews#update
#                                                    DELETE   /reviews/:id(.:format)                                                                            reviews#destroy
#                                         new_review GET      /lokaler/:space_id/new_review(.:format)                                                           reviews#new
#                                         admin_root GET      /admin(.:format)                                                                                  admin/menu#index
#                              admin_dashboard_index GET      /admin/dashboard(.:format)                                                                        admin/dashboard#index
#                                admin_history_index GET      /admin/history(.:format)                                                                          admin/history#index
#                                      admin_history GET      /admin/history/:id(.:format)                                                                      admin/history#show
#                       admin_history_revert_changes POST     /admin/history/revert_changes(.:format)                                                           admin/history#revert_changes
#                                  admin_space_types GET      /admin/space_types(.:format)                                                                      admin/space_types#index
#                                                    POST     /admin/space_types(.:format)                                                                      admin/space_types#create
#                               new_admin_space_type GET      /admin/space_types/new(.:format)                                                                  admin/space_types#new
#                              edit_admin_space_type GET      /admin/space_types/:id/edit(.:format)                                                             admin/space_types#edit
#                                   admin_space_type GET      /admin/space_types/:id(.:format)                                                                  admin/space_types#show
#                                                    PATCH    /admin/space_types/:id(.:format)                                                                  admin/space_types#update
#                                                    PUT      /admin/space_types/:id(.:format)                                                                  admin/space_types#update
#                                                    DELETE   /admin/space_types/:id(.:format)                                                                  admin/space_types#destroy
#                                admin_sync_statuses GET      /admin/sync_statuses(.:format)                                                                    admin/sync_statuses#index
#                                                    POST     /admin/sync_statuses(.:format)                                                                    admin/sync_statuses#create
#                              new_admin_sync_status GET      /admin/sync_statuses/new(.:format)                                                                admin/sync_statuses#new
#                             edit_admin_sync_status GET      /admin/sync_statuses/:id/edit(.:format)                                                           admin/sync_statuses#edit
#                                  admin_sync_status GET      /admin/sync_statuses/:id(.:format)                                                                admin/sync_statuses#show
#                                                    PATCH    /admin/sync_statuses/:id(.:format)                                                                admin/sync_statuses#update
#                                                    PUT      /admin/sync_statuses/:id(.:format)                                                                admin/sync_statuses#update
#                                                    DELETE   /admin/sync_statuses/:id(.:format)                                                                admin/sync_statuses#destroy
#                                   admin_user_lists GET      /admin/user_lists(.:format)                                                                       admin/user_lists#index
#                         admin_mission_control_jobs          /admin/jobs                                                                                       MissionControl::Jobs::Engine
#                                             spaces GET      /lokaler(.:format)                                                                                spaces#index
#                                                    POST     /lokaler(.:format)                                                                                spaces#create
#                                         edit_space GET      /lokaler/:id/edit(.:format)                                                                       spaces#edit
#                                              space GET      /lokaler/:id(.:format)                                                                            spaces#show
#                                                    PATCH    /lokaler/:id(.:format)                                                                            spaces#update
#                                                    PUT      /lokaler/:id(.:format)                                                                            spaces#update
#                                                    DELETE   /lokaler/:id(.:format)                                                                            spaces#destroy
#                                          new_space GET      /nytt-lokale(.:format)                                                                            spaces#new
#                                         edit_field GET      /lokaler/:id/edit/:field(.:format)                                                                spaces#edit_field
#                                  fullscreen_images GET      /lokaler/:id/images/:start(.:format)                                                              spaces#fullscreen_images
#                                    rect_for_spaces GET      /rect_for_spaces(.:format)                                                                        spaces#rect_for_spaces
#                                     address_search GET      /address_search(.:format)                                                                         spaces#address_search
#                                   check_duplicates GET      /check_duplicates(.:format)                                                                       spaces#check_duplicates
#   activate_personal_space_list_personal_space_list POST     /lister/:id/activate(.:format)                                                                    active_personal_space_lists#create
# deactivate_personal_space_list_personal_space_list POST     /lister/:id/deactivate(.:format)                                                                  active_personal_space_lists#destroy
#             personal_space_list_shared_with_public GET      /lister/:personal_space_list_id/shared_with_public(.:format)                                      personal_space_lists/shared_with_publics#show
#                                                    DELETE   /lister/:personal_space_list_id/shared_with_public(.:format)                                      personal_space_lists/shared_with_publics#destroy
#                                                    POST     /lister/:personal_space_list_id/shared_with_public(.:format)                                      personal_space_lists/shared_with_publics#create
#                 personal_space_list_shared_with_me GET      /lister/:personal_space_list_id/shared_with_me(.:format)                                          personal_space_lists/shared_with_mes#show
#                                                    DELETE   /lister/:personal_space_list_id/shared_with_me(.:format)                                          personal_space_lists/shared_with_mes#destroy
#                                                    POST     /lister/:personal_space_list_id/shared_with_me(.:format)                                          personal_space_lists/shared_with_mes#create
#               status_for_personal_space_list_space GET      /lister/:personal_space_list_id/lokale/:id/space_in_list(.:format)                                personal_space_lists/space_in_list#show
#                   add_to_personal_space_list_space POST     /lister/:personal_space_list_id/lokale/:id/space_in_list(.:format)                                personal_space_lists/space_in_list#create
#              remove_from_personal_space_list_space DELETE   /lister/:personal_space_list_id/lokale/:id/space_in_list(.:format)                                personal_space_lists/space_in_list#destroy
#       edit_personal_space_list_space_personal_note GET      /lister/:personal_space_list_id/lokale/:space_id/personlige_notater/:id/edit(.:format)            personal_space_lists/personal_notes#edit
#            personal_space_list_space_personal_note PATCH    /lister/:personal_space_list_id/lokale/:space_id/personlige_notater/:id(.:format)                 personal_space_lists/personal_notes#update
#                                                    PUT      /lister/:personal_space_list_id/lokale/:space_id/personlige_notater/:id(.:format)                 personal_space_lists/personal_notes#update
#      edit_personal_space_list_space_contact_status GET      /lister/:personal_space_list_id/lokale/:space_id/status/:id/edit(.:format)                        personal_space_lists/contact_status#edit
#           personal_space_list_space_contact_status PATCH    /lister/:personal_space_list_id/lokale/:space_id/status/:id(.:format)                             personal_space_lists/contact_status#update
#                                                    PUT      /lister/:personal_space_list_id/lokale/:space_id/status/:id(.:format)                             personal_space_lists/contact_status#update
#                         personal_space_list_spaces GET      /lister/:personal_space_list_id/lokale(.:format)                                                  spaces#index
#                                                    POST     /lister/:personal_space_list_id/lokale(.:format)                                                  spaces#create
#                      new_personal_space_list_space GET      /lister/:personal_space_list_id/lokale/new(.:format)                                              spaces#new
#                     edit_personal_space_list_space GET      /lister/:personal_space_list_id/lokale/:id/edit(.:format)                                         spaces#edit
#                          personal_space_list_space GET      /lister/:personal_space_list_id/lokale/:id(.:format)                                              spaces#show
#                                                    PATCH    /lister/:personal_space_list_id/lokale/:id(.:format)                                              spaces#update
#                                                    PUT      /lister/:personal_space_list_id/lokale/:id(.:format)                                              spaces#update
#                                                    DELETE   /lister/:personal_space_list_id/lokale/:id(.:format)                                              spaces#destroy
#                               personal_space_lists GET      /lister(.:format)                                                                                 personal_space_lists#index
#                                                    POST     /lister(.:format)                                                                                 personal_space_lists#create
#                            new_personal_space_list GET      /lister/new(.:format)                                                                             personal_space_lists#new
#                           edit_personal_space_list GET      /lister/:id/edit(.:format)                                                                        personal_space_lists#edit
#                                personal_space_list GET      /lister/:id(.:format)                                                                             personal_space_lists#show
#                                                    PATCH    /lister/:id(.:format)                                                                             personal_space_lists#update
#                                                    PUT      /lister/:id(.:format)                                                                             personal_space_lists#update
#                                                    DELETE   /lister/:id(.:format)                                                                             personal_space_lists#destroy
#                                       space_images GET      /space_images(.:format)                                                                           space_images#index
#                                                    POST     /space_images(.:format)                                                                           space_images#create
#                                    new_space_image GET      /space_images/new(.:format)                                                                       space_images#new
#                                   edit_space_image GET      /space_images/:id/edit(.:format)                                                                  space_images#edit
#                                        space_image GET      /space_images/:id(.:format)                                                                       space_images#show
#                                                    PATCH    /space_images/:id(.:format)                                                                       space_images#update
#                                                    PUT      /space_images/:id(.:format)                                                                       space_images#update
#                                                    DELETE   /space_images/:id(.:format)                                                                       space_images#destroy
#                                spaces_upload_image POST     /spaces/upload_image(.:format)                                                                    space_images#upload_image
#                                                    GET      /assets/*name(.:format)                                                                           redirect(301)
#                                 rails_health_check GET      /up(.:format)                                                                                     rails/health#show
#                   turbo_recede_historical_location GET      /recede_historical_location(.:format)                                                             turbo/native/navigation#recede
#                   turbo_resume_historical_location GET      /resume_historical_location(.:format)                                                             turbo/native/navigation#resume
#                  turbo_refresh_historical_location GET      /refresh_historical_location(.:format)                                                            turbo/native/navigation#refresh
#                                               page GET      /pages/*id                                                                                        high_voltage/pages#show
#                      rails_postmark_inbound_emails POST     /rails/action_mailbox/postmark/inbound_emails(.:format)                                           action_mailbox/ingresses/postmark/inbound_emails#create
#                         rails_relay_inbound_emails POST     /rails/action_mailbox/relay/inbound_emails(.:format)                                              action_mailbox/ingresses/relay/inbound_emails#create
#                      rails_sendgrid_inbound_emails POST     /rails/action_mailbox/sendgrid/inbound_emails(.:format)                                           action_mailbox/ingresses/sendgrid/inbound_emails#create
#                rails_mandrill_inbound_health_check GET      /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#health_check
#                      rails_mandrill_inbound_emails POST     /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#create
#                       rails_mailgun_inbound_emails POST     /rails/action_mailbox/mailgun/inbound_emails/mime(.:format)                                       action_mailbox/ingresses/mailgun/inbound_emails#create
#                     rails_conductor_inbound_emails GET      /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#index
#                                                    POST     /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#create
#                  new_rails_conductor_inbound_email GET      /rails/conductor/action_mailbox/inbound_emails/new(.:format)                                      rails/conductor/action_mailbox/inbound_emails#new
#                      rails_conductor_inbound_email GET      /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                                      rails/conductor/action_mailbox/inbound_emails#show
#           new_rails_conductor_inbound_email_source GET      /rails/conductor/action_mailbox/inbound_emails/sources/new(.:format)                              rails/conductor/action_mailbox/inbound_emails/sources#new
#              rails_conductor_inbound_email_sources POST     /rails/conductor/action_mailbox/inbound_emails/sources(.:format)                                  rails/conductor/action_mailbox/inbound_emails/sources#create
#              rails_conductor_inbound_email_reroute POST     /rails/conductor/action_mailbox/:inbound_email_id/reroute(.:format)                               rails/conductor/action_mailbox/reroutes#create
#           rails_conductor_inbound_email_incinerate POST     /rails/conductor/action_mailbox/:inbound_email_id/incinerate(.:format)                            rails/conductor/action_mailbox/incinerates#create
#                                 rails_service_blob GET      /rails/active_storage/blobs/redirect/:signed_id/*filename(.:format)                               active_storage/blobs/redirect#show
#                           rails_service_blob_proxy GET      /rails/active_storage/blobs/proxy/:signed_id/*filename(.:format)                                  active_storage/blobs/proxy#show
#                                                    GET      /rails/active_storage/blobs/:signed_id/*filename(.:format)                                        active_storage/blobs/redirect#show
#                          rails_blob_representation GET      /rails/active_storage/representations/redirect/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations/redirect#show
#                    rails_blob_representation_proxy GET      /rails/active_storage/representations/proxy/:signed_blob_id/:variation_key/*filename(.:format)    active_storage/representations/proxy#show
#                                                    GET      /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)          active_storage/representations/redirect#show
#                                 rails_disk_service GET      /rails/active_storage/disk/:encoded_key/*filename(.:format)                                       active_storage/disk#show
#                          update_rails_disk_service PUT      /rails/active_storage/disk/:encoded_token(.:format)                                               active_storage/disk#update
#                               rails_direct_uploads POST     /rails/active_storage/direct_uploads(.:format)                                                    active_storage/direct_uploads#create
#
# Routes for MissionControl::Jobs::Engine:
#     application_queue_pause DELETE /applications/:application_id/queues/:queue_id/pause(.:format) mission_control/jobs/queues/pauses#destroy
#                             POST   /applications/:application_id/queues/:queue_id/pause(.:format) mission_control/jobs/queues/pauses#create
#          application_queues GET    /applications/:application_id/queues(.:format)                 mission_control/jobs/queues#index
#           application_queue GET    /applications/:application_id/queues/:id(.:format)             mission_control/jobs/queues#show
#       application_job_retry POST   /applications/:application_id/jobs/:job_id/retry(.:format)     mission_control/jobs/retries#create
#     application_job_discard POST   /applications/:application_id/jobs/:job_id/discard(.:format)   mission_control/jobs/discards#create
#    application_job_dispatch POST   /applications/:application_id/jobs/:job_id/dispatch(.:format)  mission_control/jobs/dispatches#create
#    application_bulk_retries POST   /applications/:application_id/jobs/bulk_retries(.:format)      mission_control/jobs/bulk_retries#create
#   application_bulk_discards POST   /applications/:application_id/jobs/bulk_discards(.:format)     mission_control/jobs/bulk_discards#create
#             application_job GET    /applications/:application_id/jobs/:id(.:format)               mission_control/jobs/jobs#show
#            application_jobs GET    /applications/:application_id/:status/jobs(.:format)           mission_control/jobs/jobs#index
#         application_workers GET    /applications/:application_id/workers(.:format)                mission_control/jobs/workers#index
#          application_worker GET    /applications/:application_id/workers/:id(.:format)            mission_control/jobs/workers#show
# application_recurring_tasks GET    /applications/:application_id/recurring_tasks(.:format)        mission_control/jobs/recurring_tasks#index
#  application_recurring_task GET    /applications/:application_id/recurring_tasks/:id(.:format)    mission_control/jobs/recurring_tasks#show
#                             PATCH  /applications/:application_id/recurring_tasks/:id(.:format)    mission_control/jobs/recurring_tasks#update
#                             PUT    /applications/:application_id/recurring_tasks/:id(.:format)    mission_control/jobs/recurring_tasks#update
#                      queues GET    /queues(.:format)                                              mission_control/jobs/queues#index
#                       queue GET    /queues/:id(.:format)                                          mission_control/jobs/queues#show
#                         job GET    /jobs/:id(.:format)                                            mission_control/jobs/jobs#show
#                        jobs GET    /:status/jobs(.:format)                                        mission_control/jobs/jobs#index
#                        root GET    /                                                              mission_control/jobs/queues#index
