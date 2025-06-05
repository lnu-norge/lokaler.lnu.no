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
      sort_by = params[:sort_by] || "created_at"
      sort_direction = params[:sort_direction] == "asc" ? "asc" : "desc"

      # Skip database sorting for edit count, last edit, and space lists - we'll handle it in add_edit_counts
      return if %w[edits last_edit space_lists].include?(sort_by)

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

      @users_with_edit_counts = @users.map do |user|
        [user, edit_counts[user.id.to_s] || 0, last_edit_dates[user.id.to_s], space_list_counts[user.id] || 0]
      end

      # If sorting by edits, last edit, or space lists, return the sorted users as an ActiveRecord relation
      return unless %w[edits last_edit space_lists].include?(params[:sort_by])

      sort_direction = params[:sort_direction] == "asc" ? 1 : -1

      sorted_users = case params[:sort_by]
                     when "edits"
                       @users_with_edit_counts.sort_by { |_, count, _, _| count * sort_direction }.map(&:first)
                     when "last_edit"
                       sorted_data = @users_with_edit_counts.sort_by do |_, _, last_edit, _|
                         last_edit || Time.zone.at(0) # Use epoch time for users with no edits
                       end
                       sorted_data = sorted_data.reverse if sort_direction == -1
                       sorted_data.map(&:first)
                     when "space_lists"
                       @users_with_edit_counts.sort_by do |_, _, _, space_list_count|
                         space_list_count * sort_direction
                       end.map(&:first)
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
       "Lister", "Opprettet", "Sist oppdatert"]
    end

    def csv_row_for_user(user) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      user_data = @users_with_edit_counts.find { |u, _, _, _| u.id == user.id }
      edit_count = user_data&.second || 0
      last_edit = user_data&.third
      space_list_count = user_data&.fourth || 0

      [
        user.id,
        user.full_name,
        user.first_name,
        user.last_name,
        user.email,
        user.organization_name,
        user.robot? ? "Robot" : "Menneske",
        user.admin? ? "Ja" : "Nei",
        edit_count,
        last_edit&.strftime("%Y-%m-%d %H:%M") || "-",
        space_list_count,
        user.created_at.strftime("%Y-%m-%d %H:%M"),
        user.updated_at.strftime("%Y-%m-%d %H:%M")
      ]
    end
  end
end
