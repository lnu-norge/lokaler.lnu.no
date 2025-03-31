# frozen_string_literal: true

module Admin
  class DashboardController < BaseControllers::AuthenticateAsAdminController # rubocop:disable Metrics/ClassLength
    PERIODS_TO_GROUP_BY = %i[
      hour
      day
      week
      month
      year
    ].freeze
    def index
      set_date_range
      set_period_grouping

      statistics
    end

    private

    def statistics
      paper_trail_statistics
      space_statistics
      space_fields_statistics
      review_statistics
      facility_review_statistics
      space_facility_statistics
      space_group_statistics
      user_statistics
      list_statistics
    end

    def space_group_statistics
      @space_groups = SpaceGroup.count
      @space_groups_with_spaces = SpaceGroup.joins(:spaces).distinct.count
      @space_groups_with_terms_and_pricing = space_groups_with_rich_text("terms_and_pricing")
      @space_groups_with_how_to_book = space_groups_with_rich_text("how_to_book")
      @space_groups_with_about = space_groups_with_rich_text("about")
    end

    def paper_trail_statistics
      @changes_created_by_system = PaperTrail::Version
                                   .where(whodunnit: nil)
                                   .group("item_type")
                                   .group_by_period(@period_grouping, :created_at, range: @date_range).count
      @changes_created_by_system_count = PaperTrail::Version
                                         .where(created_at: @date_range)
                                         .where(whodunnit: nil)
                                         .count

      user_changes_from_paper_trail
      most_users_creating_changes
    end

    def user_changes_from_paper_trail
      @changes_created_by_users = PaperTrail::Version
                                  .where.not(whodunnit: nil)
                                  .group("item_type")
                                  .group_by_period(@period_grouping, :created_at, range: @date_range).count
      @changes_created_by_users_count = PaperTrail::Version
                                        .where(created_at: @date_range)
                                        .where.not(whodunnit: nil)
                                        .count

      @unique_users_creating_changes = PaperTrail::Version
                                       .where.not(whodunnit: nil)
                                       .group_by_period(@period_grouping, :created_at,
                                                        range: @date_range)
                                       .distinct
                                       .count(:whodunnit)
      @unique_users_creating_changes_count = PaperTrail::Version
                                             .where(created_at: @date_range)
                                             .where.not(whodunnit: nil)
                                             .distinct
                                             .count(:whodunnit)
    end

    def most_users_creating_changes
      @most_changes_per_user = PaperTrail::Version
                               .where(created_at: @date_range)
                               .where.not(whodunnit: nil)
                               .group(:whodunnit)
                               .count
                               .sort_by { |_, count| count }
                               .reverse
      @most_changes_per_user_limit = 5
    end

    def space_statistics
      @spaces_created = Space.group_by_period(@period_grouping, :created_at, range: @date_range).count
      @spaces_created_count = Space.where(created_at: @date_range).count
      @space_count = Space.count
    end

    def space_fields_statistics # rubocop:disable Metrics/AbcSize
      @spaces_with_title = Space.where.not(title: nil).count
      @spaces_with_image = Space.includes(:images).where.not(images: { id: nil }).count
      @spaces_with_facility_reviews = Space.includes(:facility_reviews).where.not(facility_reviews: { id: nil }).count
      @spaces_with_reviews = Space.includes(:reviews).where.not(reviews: { id: nil }).count
      @spaces_with_space_contacts = Space.includes(:space_contacts).where.not(space_contacts: { id: nil }).count
      @spaces_with_space_group = Space.includes(:space_group).where.not(space_group: { id: nil }).count
      @spaces_with_space_type = Space.includes(:space_types).where.not(space_types: { id: nil }).count
      @spaces_with_address = Space.where.not(address: nil).count
      @spaces_with_fylke = Space.where.not(fylke_id: nil).count
      @spaces_with_lat_lng = Space.where.not(lat: nil).count
      @spaces_with_location_description = Space.where.not(location_description: [nil, ""]).count
      @spaces_in_a_list = Space.joins(:personal_space_lists).distinct.count
      @spaces_with_how_to_book = spaces_with_rich_text("how_to_book")
      @spaces_with_terms_and_pricing = spaces_with_rich_text("terms_and_pricing")
      @spaces_with_more_info = spaces_with_rich_text("more_info")
    end

    def review_statistics
      @reviews_created = Review
                         .group_by_period(@period_grouping, :created_at, range: @date_range).count
      @reviews_created_count = Review.where(created_at: @date_range).count
    end

    def facility_review_statistics
      @facility_reviews_created = FacilityReview
                                  .group("experience")
                                  .group_by_period(@period_grouping, :created_at,
                                                   range: @date_range).count
      @facility_reviews_created_count = FacilityReview.where(created_at: @date_range).count
    end

    def space_facility_statistics
      @relevant_space_facilities_count = SpaceFacility.where(relevant: true).count
      @relevant_space_facilities_with_known_experience = SpaceFacility
                                                         .where(relevant: true)
                                                         .where.not(experience: :unknown)
                                                         .count
    end

    def user_statistics # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      top_organizations = User
                          .where(created_at: @date_range)
                          .group(:organization)
                          .count.sort_by { |_, count| -count }
                          .take(6).filter(&:last).map(&:first)

      sql_for_gropuing_by_organization = Arel.sql(
        <<~SQL.squish
          CASE
            WHEN organization = '' THEN 'Ingen organisasjon'
            WHEN organization IN (
              #{top_organizations.map do |org|
                "'#{org}'"
              end.join(',')}
              ) THEN organization
            ELSE 'Annen organisasjon'
          END
        SQL
      )

      @users_created = User
                       .group(sql_for_gropuing_by_organization)
                       .group_by_period(
                         @period_grouping,
                         :created_at,
                         range: @date_range
                       ).count

      @users_created_count = User.where(created_at: @date_range).count
      @users_count = User.count
      @users_with_reviews = User.joins(:reviews)
                                .where.not(reviews: { id: nil })
                                .distinct.count
      @users_with_facility_reviews = User.joins(:facility_reviews)
                                         .where.not(facility_reviews: { id: nil })
                                         .distinct.count
      @users_with_organization = User.where.not(organization: [nil, ""]).count
      @users_with_first_name = User.where.not(first_name: [nil, ""]).count
      @users_with_last_name = User.where.not(last_name: [nil, ""]).count
      @admin_users = User.where(admin: true).count
      @organizations_with_user_count = User
                                       .group(:organization)
                                       .count
                                       .sort_by { |_, count| -count }
      @organizations_to_show_before_expanding_list = 5
    end

    def list_statistics
      @lists_created = PersonalSpaceList.group_by_period(@period_grouping, :created_at, range: @date_range).count
      @lists_created_count = PersonalSpaceList.where(created_at: @date_range).count
    end

    def set_period_grouping
      @period_grouping = params.permit("period_grouping")[:period_grouping].presence || default_period_grouping
    end

    def default_period_grouping
      days_of_stats_shown = @date_range.count

      case days_of_stats_shown
      when 0
        :hour
      when 1..31
        :day
      when 32..200
        :week
      when 201..720
        :month
      else
        :year
      end
    end

    def set_date_range
      start_date = params[:start_date]&.to_date || 1.year.ago.to_date
      end_date = params[:end_date]&.to_date || Date.current

      @date_range = start_date..end_date
    end

    def spaces_with_rich_text(field)
      model_with_rich_text(model: Space, field:)
    end

    def space_groups_with_rich_text(field)
      model_with_rich_text(model: SpaceGroup, field:)
    end

    def model_with_rich_text(model:, field:)
      model.joins(:"rich_text_#{field}").where.not(action_text_rich_texts: { body: [nil, ""] }).count
    end
  end
end
