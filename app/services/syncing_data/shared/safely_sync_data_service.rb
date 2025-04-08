# frozen_string_literal: true

module SyncingData
  module Shared
    class SafelySyncDataService # rubocop:disable Metrics/ClassLength
      def initialize(
        user_or_robot_doing_the_syncing:,
        model:,
        field:,
        new_data:,
        allow_empty_new_data: false
      )
        @user = user_or_robot_doing_the_syncing
        @model = model
        @field = field
        @new_data = new_data
        @allow_empty_new_data = allow_empty_new_data
      end

      def safely_sync_data
        return unless should_sync_be_allowed?

        PaperTrail.request(whodunnit: @user.id) do
          @model.update(@field => @new_data)
        end
      end

      def should_sync_be_allowed?
        return false if new_data_is_empty_and_empty_data_is_not_allowed?
        return true if no_info_about_who_last_set_the_field?
        return false if proposed_new_data_is_old_data?
        return true if no_existing_data_would_be_overwritten?
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

      def no_info_about_who_last_set_the_field?
        versions_of_field_for_existing_data.empty?
      end

      def last_version_has_no_whodunnit?
        user_id_behind_last_version_of_field.blank?
      end

      def last_version_set_by_same_user?
        user_id_behind_last_version_of_field == @user.id.to_s
      end

      def last_version_set_by_robot?
        return false if user_id_behind_last_version_of_field.blank?

        User.find(user_id_behind_last_version_of_field).robot?
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

      def new_data_is_empty_and_empty_data_is_not_allowed?
        @new_data.blank? unless @allow_empty_new_data
      end

      def same_data_has_been_overwritten_before?
        return true if any_matching_rich_text_versions?
        return true if any_matching_association_versions?

        any_matching_versions?
      end

      def any_matching_rich_text_versions?
        return false unless field_is_rich_text

        versions_of_model_for_existing_data.any? do |version|
          old_data = version.reify(dup: true)
          next if old_data.blank?

          old_data.body == ActionText::Content.new(@new_data)
        end
      end

      def any_matching_association_versions?
        return false unless data_is_association_to_other_model

        id_of_new_data = @new_data&.id || @new_data
        versions_of_model_for_existing_data
          .where_object(field_name_if_association => id_of_new_data)
          .any?
      end

      def field_name_if_association
        "#{@field}_id"
      end

      def field_name
        @field.to_s
      end

      def field_name_in_database
        return field_name_if_association if data_is_association_to_other_model

        field_name
      end

      def data_is_association_to_other_model
        @model.class.reflect_on_association(@field).present?
      end

      def any_matching_versions?
        versions_of_model_for_existing_data
          .where_object(@field => @new_data)
          .any?
      end

      def versions_of_model_for_existing_data
        if field_is_rich_text
          @model.public_send(@field).versions
        else
          @model.versions
        end
      end

      def versions_of_field_for_existing_data
        return versions_of_model_for_existing_data if field_is_rich_text

        versions_of_model_for_existing_data.select do |version|
          object_changes = YAML.safe_load(
            version.object_changes,
            aliases: true,
            permitted_classes: ActiveRecord.yaml_column_permitted_classes
          )

          object_changes.key?(field_name_in_database)
        end
      end

      def last_version_of_field
        versions_of_field_for_existing_data.last
      end

      def user_id_behind_last_version_of_field
        last_version_of_field.whodunnit
      end

      def class_name_for_data
        existing_data.class.name
      end

      def field_is_rich_text
        class_name_for_data == "ActionText::RichText"
      end
    end
  end
end
