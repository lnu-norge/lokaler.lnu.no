# frozen_string_literal: true

module Admin
  class UserListsController < BaseControllers::AuthenticateAsAdminController
    def index
      @users = User.all
      filter_users
      paginate_users
      @permitted_params = params.permit(:search, :type, :admin, :sort_by, :sort_direction, :page, :start_date,
                                        :end_date, organization_names: [])
      @available_organizations = User.where.not(organization_name: [nil, ""]).distinct.pluck(:organization_name).sort
    end

    private

    def filter_users
      filter_by_type
      filter_by_organization
      filter_by_admin_status
      filter_by_date_range
      filter_by_search
      sort_users
    end

    def filter_by_type
      return if params[:type].blank?

      case params[:type]
      when "humans"
        @users = @users.humans
      when "robots"
        @users = @users.robots
      end
    end

    def filter_by_organization
      return unless params[:organization_names].present? && params[:organization_names].any?(&:present?)

      @users = @users.where(organization_name: params[:organization_names])
    end

    def filter_by_admin_status
      return if params[:admin].blank?

      case params[:admin]
      when "true"
        @users = @users.where(admin: true)
      when "false"
        @users = @users.where(admin: false)
      end
    end

    def filter_by_date_range
      start_date = params[:start_date]&.to_date
      end_date = params[:end_date]&.to_date

      if start_date && end_date
        @users = @users.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
      elsif start_date
        @users = @users.where(created_at: start_date.beginning_of_day..)
      elsif end_date
        @users = @users.where(created_at: ..end_date.end_of_day)
      end
    end

    def filter_by_search
      return if params[:search].blank?

      search_term = "%#{params[:search]}%"
      @users = @users.where(
        "first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ? OR organization_name ILIKE ?",
        search_term, search_term, search_term, search_term
      )
    end

    def sort_users
      sort_by = params[:sort_by] || "created_at"
      sort_direction = params[:sort_direction] == "asc" ? "asc" : "desc"

      @users = case sort_by
               when "name"
                 @users.order("first_name #{sort_direction}, last_name #{sort_direction}")
               when "organization"
                 @users.order("organization_name #{sort_direction}")
               else
                 @users.order("#{sort_by} #{sort_direction}")
               end
    end

    def paginate_users
      @pagy, @users = pagy(@users, limit: 50)
    end
  end
end
