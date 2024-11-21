# frozen_string_literal: true

module Admin
  class DashboardController < BaseControllers::AuthenticateAsAdminController
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
      review_statistics
      facility_review_statistics
      user_statistics
      list_statistics
    end

    def paper_trail_statistics
      @changes_created_by_system = PaperTrail::Version
                                   .where(whodunnit: nil)
                                   .group_by_period(@period_grouping, :created_at, range: @date_range).count
      @changes_created_by_users = PaperTrail::Version
                                  .where.not(whodunnit: nil)
                                  .group_by_period(@period_grouping, :created_at, range: @date_range).count
      @unique_users_creating_changes = PaperTrail::Version
                                       .where.not(whodunnit: nil)
                                       .group_by_period(@period_grouping, :created_at,
                                                        range: @date_range)
                                       .distinct
                                       .count(:whodunnit)
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
    end

    def review_statistics
      @reviews_created = Review.group_by_period(@period_grouping, :created_at, range: @date_range).count
    end

    def facility_review_statistics
      @facility_reviews_created = FacilityReview.group_by_period(@period_grouping, :created_at,
                                                                 range: @date_range).count
    end

    def user_statistics
      @users_created = User.group_by_period(@period_grouping, :created_at, range: @date_range).count
    end

    def list_statistics
      @lists_created = PersonalSpaceList.group_by_period(@period_grouping, :created_at, range: @date_range).count
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
  end
end
