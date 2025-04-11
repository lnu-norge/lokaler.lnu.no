# frozen_string_literal: true

module SyncingData
  module FromBrreg
    module SafelyUpdateDataHelper
      private

      def default_title_for_space_contact
        "Sentralbord"
      end

      def safely_update_sentralbord_data(space_contact:, contact_information:)
        safely_update(
          space_contact:,
          field: :title,
          new_data: default_title_for_space_contact
        )
        safely_update_data(space_contact:, contact_information:)
      end

      def safely_update_data(space_contact:, contact_information:)
        safely_update(
          space_contact:,
          field: :email,
          new_data: contact_information[:email]
        )
        safely_update(
          space_contact:,
          field: :telephone,
          new_data: contact_information[:phone] || contact_information[:mobile]
        )
        safely_update(
          space_contact:,
          field: :url,
          new_data: contact_information[:website]
        )
      end

      def safely_update_sentralbord_mobile_number_data(space_contact:, contact_information:)
        safely_update(
          space_contact:,
          field: :telephone,
          new_data: contact_information[:mobile]
        )
      end

      def create_new_space_contact(space:, contact_information:)
        return if not_enough_data_to_create_new_contact?(contact_information)

        space.space_contacts.create!(
          title: default_title_for_space_contact,
          email: contact_information[:email],
          telephone: contact_information[:phone] || contact_information[:mobile],
          url: contact_information[:website]
        )

        create_space_contact_for_mobile_number_if_needed(space:, contact_information:)
      end

      def create_space_contact_for_mobile_number_if_needed(space:, contact_information:)
        has_mobile = contact_information[:mobile].present?
        has_phone = contact_information[:phone].present?
        return unless has_mobile && has_phone

        space.space_contacts.create!(
          title: "#{default_title_for_space_contact} (mobil)",
          telephone: contact_information[:mobile]
        )
      end

      def not_enough_data_to_create_new_contact?(contact_information)
        contact_information[:website].blank? &&
          contact_information[:email].blank? &&
          contact_information[:phone].blank? &&
          contact_information[:mobile].blank?
      end

      def safely_update(space_contact:, field:, new_data:)
        safely_sync_data_service(space_contact:, field:, new_data:)
          .safely_sync_data
      end

      def safely_sync_data_service(space_contact:, field:, new_data:)
        SyncingData::Shared::SafelySyncDataService.new(
          user_or_robot_doing_the_syncing: Robot.brreg,
          model: space_contact,
          field:,
          new_data:
        )
      end
    end
  end
end
