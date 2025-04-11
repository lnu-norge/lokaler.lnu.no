# frozen_string_literal: true

module SyncingData
  module FromBrreg
    BRREG_BASE_URL = "https://data.brreg.no/enhetsregisteret/api"
    class RunSyncService < ApplicationService
      include TaggedLogHelper
      include FetchContactInformationHelper
      include SyncStatusHelper

      def initialize
        @count_logger = count_logger

        super
      end

      def call
        @count_logger.start
        sync_spaces
        @count_logger.stop
      end

      private

      def count_logger
        @count_logger ||= SyncingData::Shared::CountLogger.new(
          name: "BRREG sync",
          limit_versions_to_user_id: Robot.brreg.id,
          logger: rails_logger_with_tags
        )
      end

      def sync_spaces
        spaces_with_organization_numbers.each do |space|
          start_sync_log(space.organization_number)
          sync_space_contacts_for(space)

          log_successful_sync(space.organization_number)
        rescue StandardError => e
          log_failed_sync(space.organization_number, e)
        end
      end

      def sync_space_contacts_for(space)
        logger.debug { "Syncing space #{space.id}" }

        new_contact_information = contact_information_from_brreg_for(org_number: space.organization_number)

        PaperTrail.request(whodunnit: Robot.brreg.id) do
          # First check if we have any space_contacts already, if not - create a new one
          space_contacts_for_space = space.space_contacts
          if space_contacts_for_space.empty?
            return create_new_space_contact(space:,
                                            contact_information: new_contact_information)
          end

          # Else, check if any of the existing space_contacts should be updated with the new data:
          space_contacts_for_space.map do |space_contact|
            email_sync_service = sync_service_for(
              space_contact:,
              field: :email,
              new_data: new_contact_information[:email]
            )
            email_sync_service.proposed_new_data_is_old_data?
          end
        end
      end

      def create_new_space_contact(space:, contact_information:)
        space.space_contacts.create!(
          title: default_title_for_space_contact,
          email: contact_information[:email],
          telephone: contact_information[:phone] || contact_information[:mobile],
          url: contact_information[:website]
        )

        has_mobile = contact_information[:mobile].present?
        has_phone = contact_information[:phone].present?
        has_both_mobile_and_phone = has_mobile && has_phone
        return unless has_both_mobile_and_phone

        space.space_contacts.create!(
          title: "#{default_title_for_space_contact} (mobil)",
          telephone: contact_information[:mobile]
        )
      end

      def default_title_for_space_contact
        "Sentralbord"
      end

      def sync_email(space_contacts_for_space, email)
        # First find out which space_contact we want to update,
        # or if we need to create a new one

        space_contacts_for_space.any? do |contact|
          sync_service = sync_service_for(
            space_contact: contact,
            field: :email,
            new_data: email
          )

          sync_service.safely_sync_data
        end
      end

      def sync_service_for(space_contact:, field:, new_data:)
        SyncingData::Shared::SafelySyncDataService.new(
          user_or_robot_doing_the_syncing: Robot.brreg,
          model: space_contact,
          field:,
          new_data:
        )
      end

      def spaces_with_organization_numbers
        Space.where.not(organization_number: nil)
      end
    end
  end
end
