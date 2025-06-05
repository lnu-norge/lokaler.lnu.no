# frozen_string_literal: true

module Admin
  class UserListsController < BaseControllers::AuthenticateAsAdminController # rubocop:disable Metrics/ClassLength
    def index
      @users = User.all
      filter_users
      add_edit_counts

      respond_to do |format|
        format.html do
          paginate_users
        end
        format.csv do
          # Don't paginate for CSV export - export all filtered results
          send_data generate_csv(@users), filename: "users-#{Date.current}.csv"
        end
      end

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
      sort_by = params[:sort_by] || "last_active"
      sort_direction = params[:sort_direction] == "asc" ? "asc" : "desc"

      # Skip database sorting for edit count, last edit, space lists,
      # active days, and last active - we'll handle it in add_edit_counts
      return if
        %w[edits last_edit space_lists active_days last_active]
        .include?(sort_by)

      @users = apply_sorting(@users, sort_by, sort_direction)
    end

    def apply_sorting(users, sort_by, sort_direction)
      case sort_by
      when "name"
        users.order("first_name #{sort_direction}, last_name #{sort_direction}")
      when "organization"
        users.order("organization_name #{sort_direction}")
      else
        users.order("#{sort_by} #{sort_direction}")
      end
    end

    def add_edit_counts # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
      user_ids = @users.pluck(:id)
      edit_counts = PaperTrail::Version
                    .where(whodunnit: user_ids)
                    .group(:whodunnit)
                    .count

      last_edit_dates = PaperTrail::Version
                        .where(whodunnit: user_ids)
                        .group(:whodunnit)
                        .maximum(:created_at)

      space_list_counts = PersonalSpaceList
                          .where(user_id: user_ids)
                          .group(:user_id)
                          .count

      active_days_counts = UserPresenceLog
                           .where(user_id: user_ids)
                           .group(:user_id)
                           .count

      last_active_dates = UserPresenceLog
                          .where(user_id: user_ids)
                          .group(:user_id)
                          .maximum(:date)

      @users_with_data = @users.map do |user|
        {
          user: user,
          edit_count: edit_counts[user.id.to_s] || 0,
          last_edit_date: last_edit_dates[user.id.to_s],
          space_list_count: space_list_counts[user.id] || 0,
          active_days_count: active_days_counts[user.id] || 0,
          last_active_date: last_active_dates[user.id]
        }
      end

      # If sorting by edits, last edit, space lists, active days,
      # or last active, return the sorted users as an ActiveRecord relation
      return unless %w[edits last_edit space_lists active_days last_active]
                    .include?(params[:sort_by])

      sort_direction = params[:sort_direction] == "asc" ? 1 : -1

      sorted_users = case params[:sort_by]
                     when "edits"
                       @users_with_data.sort_by { |data| data[:edit_count] * sort_direction }.pluck(:user)
                     when "last_edit"
                       sorted_data = @users_with_data.sort_by do |data|
                         data[:last_edit_date] || Time.zone.at(0) # Use epoch time for users with no edits
                       end
                       sorted_data = sorted_data.reverse if sort_direction == -1
                       sorted_data.pluck(:user)
                     when "space_lists"
                       @users_with_data.sort_by do |data|
                         data[:space_list_count] * sort_direction
                       end.pluck(:user)
                     when "active_days"
                       @users_with_data.sort_by do |data|
                         data[:active_days_count] * sort_direction
                       end.pluck(:user)
                     when "last_active"
                       sorted_data = @users_with_data.sort_by do |data|
                         data[:last_active_date] || Date.new(1970, 1, 1) # Use epoch date for users with no activity
                       end
                       sorted_data = sorted_data.reverse if sort_direction == -1
                       sorted_data.pluck(:user)
                     end

      sorted_ids = sorted_users.map(&:id)

      # Create a new relation with the sorted order using a CASE statement
      @users = User.where(id: sorted_ids)
                   .order(Arel.sql("CASE #{sorted_ids.map.with_index do |id, index|
                     "WHEN id = #{id} THEN #{index}"
                   end.join(' ')} END"))
    end

    def paginate_users
      @pagy, @users = pagy(@users, limit: 50)
    end

    def generate_csv(users)
      require "csv"

      CSV.generate(headers: true) do |csv|
        csv << csv_headers
        users.find_each { |user| csv << csv_row_for_user(user) }
      end
    end

    def csv_headers
      ["ID", "Navn", "Fornavn", "Etternavn", "E-post", "Organisasjon", "Type", "Admin", "Endringer", "Siste endring",
       "Lister", "Aktive dager", "Sist aktiv", "Opprettet", "Sist oppdatert"]
    end

    def csv_row_for_user(user) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      user_data = @users_with_data.find { |data| data[:user].id == user.id }

      [
        user.id,
        user.full_name,
        user.first_name,
        user.last_name,
        user.email,
        user.organization_name,
        user.robot? ? "Robot" : "Menneske",
        user.admin? ? "Ja" : "Nei",
        user_data&.dig(:edit_count) || 0,
        user_data&.dig(:last_edit_date)&.strftime("%Y-%m-%d %H:%M") || "-",
        user_data&.dig(:space_list_count) || 0,
        user_data&.dig(:active_days_count) || 0,
        user_data&.dig(:last_active_date)&.strftime("%Y-%m-%d") || "-",
        user.created_at.strftime("%Y-%m-%d %H:%M"),
        user.updated_at.strftime("%Y-%m-%d %H:%M")
      ]
    end
  end
end
