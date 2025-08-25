# frozen_string_literal: true

module SyncingData
  module FromBrreg
    module SyncSpaceContactHelper # rubocop:disable Metrics/ModuleLength
      include SafelyUpdateDataHelper

      private

      def sync_space_contacts_for(space)
        PaperTrail.request(whodunnit: Robot.brreg.id) do
          run_sync(
            space:,
            contact_information: cached_contact_information_for(org_number: space.organization_number)
          )
        end
      end

      def cached_contact_information_for(org_number:)
        return contact_information_from_brreg_for(org_number: org_number) if @force_fresh_sync

        cache_expires_in = @time_between_syncs - 1.day
        cache_expires_in = 1.day if cache_expires_in.negative?

        Rails.cache.fetch(
          "brreg:contact_information_for:#{org_number}",
          expires_in: cache_expires_in
        ) do
          contact_information_from_brreg_for(org_number: org_number)
        end
      end

      def sync_any_existing_sentralbord?(space_contacts_for_space:, contact_information:)
        existing_sentralbord = space_contacts_for_space.filter do |space_contact|
          space_contact_is_sentralbord?(space_contact:)
        end

        only_one_existing_sentralbord = existing_sentralbord.length == 1
        return false unless only_one_existing_sentralbord

        safely_update_sentralbord_data(space_contact: existing_sentralbord.first, contact_information:)
        true
      end

      def remove_sentralbord_from(space_contacts_for_space:)
        space_contacts_for_space.reject do |space_contact|
          space_contact_is_sentralbord?(space_contact:)
        end
      end

      def sync_any_existing_sentralbord_mobile_number?(space_contacts_for_space:, contact_information:)
        existing_sentralbord_for_mobile_number = space_contacts_for_space.filter do |space_contact|
          space_contact_is_mobile_number_for_sentralbord?(space_contact:)
        end

        only_one_existing_sentralbord_mobile_number = existing_sentralbord_for_mobile_number.length == 1
        return false unless only_one_existing_sentralbord_mobile_number

        safely_update_sentralbord_mobile_number_data(space_contact: existing_sentralbord_for_mobile_number.first,
                                                     contact_information:)
        true
      end

      def remove_mobile_number_from(space_contacts_for_space:)
        space_contacts_for_space.reject do |space_contact|
          space_contact_is_mobile_number_for_sentralbord?(space_contact:)
        end
      end

      def after_existing_sentralbord_synced(space:, contact_information:) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
        space_contacts_for_space = space.space_contacts

        synced_existing_sentralbord = sync_any_existing_sentralbord?(space_contacts_for_space:, contact_information:)
        space_contacts_for_space = remove_sentralbord_from(space_contacts_for_space:) if synced_existing_sentralbord
        synced_mobile_number = sync_any_existing_sentralbord_mobile_number?(space_contacts_for_space:,
                                                                            contact_information:)

        if synced_mobile_number
          space_contacts_for_space = remove_mobile_number_from(space_contacts_for_space:)
        elsif synced_existing_sentralbord && contact_information[:mobile].present?
          # If we have a Sentralbord contact, but no existing mobile sentralbord,
          # then we can just make one, and then remove mobile number from
          # the list of contact information to be updated
          create_space_contact_for_mobile_number_if_needed(space:, contact_information:)
          contact_information[:mobile] = nil
        end

        mobile_number_handled =
          synced_mobile_number || contact_information[:mobile].blank?

        everything_is_handled = mobile_number_handled && synced_existing_sentralbord

        return false if everything_is_handled

        {
          contact_information_left_to_sync: contact_information,
          space_contacts_left_to_sync: space_contacts_for_space
        }
      end

      def run_sync(space:, contact_information:)
        if no_existing_or_destroyed_space_contacts_for_space?(space:)
          return create_new_space_contact(space:, contact_information:)
        end

        remaining_data = after_existing_sentralbord_synced(space:, contact_information:)
        return if remaining_data.blank?

        remaining_contact_information_to_sync = remaining_data[:contact_information_left_to_sync]
        remaining_space_contacts_to_sync = remaining_data[:space_contacts_left_to_sync]

        return unless remaining_contact_information_to_sync.values.any?(&:present?)

        sync_remaining_contact_information(space:,
                                           space_contacts_for_space: remaining_space_contacts_to_sync,
                                           contact_information: remaining_contact_information_to_sync)
      end

      def sync_remaining_contact_information(space:, space_contacts_for_space:, contact_information:) # rubocop:disable Metrics/MethodLength
        # First we want to remove any information that an existing space contact says we cannot update:
        if any_space_contact_blocks_the_update?(space:, space_contacts_for_space:,
                                                field: :email,
                                                new_data: contact_information[:email])
          contact_information[:email] = nil
        end

        if any_space_contact_blocks_the_update?(space:, space_contacts_for_space:,
                                                field: :telephone,
                                                new_data: contact_information[:phone])
          contact_information[:phone] = nil
        end

        if any_space_contact_blocks_the_update?(space:, space_contacts_for_space:,
                                                field: :telephone,
                                                new_data: contact_information[:mobile])
          contact_information[:mobile] = nil
        end

        if any_space_contact_blocks_the_update?(space:, space_contacts_for_space:,
                                                field: :url,
                                                new_data: contact_information[:website])
          contact_information[:website] = nil
        end

        # Then, if we still have any data, create a new space contact
        create_new_space_contact(space:, contact_information: contact_information)
      end

      def any_space_contact_blocks_the_update?(space:, space_contacts_for_space:, field:, new_data:)
        # First check if any of the contacts have a reason to stop the update:
        all_existing_allow = space_contacts_for_space.all? do |space_contact|
          safely_sync_data_service(space_contact:, field:, new_data:)
            .should_sync_be_allowed?
        end
        any_existing_blocking = !all_existing_allow

        any_destroyed_blocking = data_has_been_destroyed_before?(space_id: space.id, field:, new_data:)

        any_existing_blocking || any_destroyed_blocking
      end

      def no_existing_or_destroyed_space_contacts_for_space?(space:)
        return false if space.space_contacts.any?
        return false if any_destroyed_space_contacts_for_space?(space_id: space.id)

        true
      end

      def any_destroyed_space_contacts_for_space?(space_id:)
        PaperTrail::Version
          .where(item_type: "SpaceContact", event: "destroy")
          .where_object(space_id:)
          .any?
      end

      def data_has_been_destroyed_before?(space_id:, field:, new_data:)
        return false unless new_data.present? && field.present? && space_id.present?

        PaperTrail::Version
          .where(item_type: "SpaceContact", event: "destroy")
          .where_object(space_id:, field => new_data)
          .any?
      end

      def space_contact_is_sentralbord?(space_contact:)
        # Title has Sentralbord in it, and it's not a mobile contact
        return false unless space_contact.title.include?("Sentralbord")
        return false if space_contact.title.match?(/\s\(mobil\)/)

        true
      end

      def space_contact_is_mobile_number_for_sentralbord?(space_contact:)
        return false unless space_contact.title.include?("Sentralbord")
        return false unless space_contact.title.match?(/\s\(mobil\)/)

        true
      end
    end
  end
end
