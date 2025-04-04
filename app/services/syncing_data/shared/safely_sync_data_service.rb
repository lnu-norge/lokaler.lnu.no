# frozen_string_literal: true

module SyncingData
  module Shared
    class SafelySyncDataService
      def initialize(
        user_or_robot_doing_the_syncing:,
        model:,
        field:,
        new_data:
      )
        @user = user_or_robot_doing_the_syncing
        @model = model
        @field = field
        @new_data = new_data
      end

      def safely_sync_data
        return unless should_sync_be_allowed?

        PaperTrail.request(whodunnit: @user.id) do
          @model.update!(@field => @new_data)
        end
      end

      def should_sync_be_allowed?
        return true if no_existing_data_would_be_overwritten?
        return true if existing_data_has_no_info_about_who_set_it_or_when?
        return false if proposed_new_data_is_old_data?
        return false if old_data_verifiably_set_by_other_human?

        true
      end

      private

      def proposed_new_data_is_old_data?
        return true if same_data_already_exists?
        return true if same_data_has_been_overwritten_before?

        false
      end

      def old_data_verifiably_set_by_other_human?
        return false if last_version_has_no_whodunnit?
        return false if last_version_set_by_same_user?
        return false if last_version_set_by_robot?

        true
      end

      def no_existing_data_would_be_overwritten?
        existing_data.blank?
      end

      def existing_data_has_no_info_about_who_set_it_or_when?
        versions_of_existing_data.empty?
      end

      def last_version_has_no_whodunnit?
        user_id_behind_last_version.blank?
      end

      def last_version_set_by_same_user?
        user_id_behind_last_version == @user.id.to_s
      end

      def last_version_set_by_robot?
        return false if user_id_behind_last_version.blank?

        User.find(user_id_behind_last_version).robot?
      end

      def same_data_already_exists?
        case class_name_for_data
        when "ActionText::RichText"
          existing_data.body == ActionText::Content.new(@new_data)
        else
          existing_data == @new_data
        end
      end

      def existing_data
        @model.public_send(@field)
      end

      def same_data_has_been_overwritten_before?
        case class_name_for_data
        when "ActionText::RichText"
          versions_of_existing_data.any? do |version|
            old_data = version.reify(dup: true)
            next if old_data.blank?

            old_data.body == ActionText::Content.new(@new_data)
          end
        else
          versions_of_existing_data
            .where_object(@field => @new_data)
            .any?
        end
      end

      def versions_of_existing_data
        case class_name_for_data
        when "ActionText::RichText"
          @model.public_send(@field).versions
        else
          @model.versions
        end
      end

      def last_version
        versions_of_existing_data.last
      end

      def user_id_behind_last_version
        last_version.whodunnit
      end

      def class_name_for_data
        existing_data.class.name
      end
    end
  end
end
