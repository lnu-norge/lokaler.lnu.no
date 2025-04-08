# frozen_string_literal: true

module SyncingData
  module FromNsr
    module SetSpaceGroupHelper
      private

      def set_space_group(space, school_data)
        # Offentlige skoler endrer eier i ny og ne, når kommuner og fylker endrer seg.
        # Her forsøker vi ta hensyn til det ved å lage en ny SpaceGroup om det ikke finnes
        # en eksisterende SpaceGroup allerede.

        # Only relevant for public schools:
        return unless school_data["ErOffentligSkole"]

        old_space_group = space.space_group

        # NB: For now we overwrite even human edited space groups
        # (preserving the old data, but not the title) we might want
        # to change that behaviour in the future.
        new_space_group_title = space_group_title(school_data)
        new_space_group = SpaceGroup.find_or_create_by(title: new_space_group_title)

        new_space_group.update(how_to_book: old_space_group.how_to_book) if old_space_group&.how_to_book.present?
        if old_space_group&.terms_and_pricing.present?
          new_space_group.update(terms_and_pricing: old_space_group.terms_and_pricing)
        end
        new_space_group.update(about: old_space_group.about) if old_space_group&.about.present?
        new_space_group.save

        clean_up_unused_space_group(
          space_no_longer_belonging_to_space_group: space,
          space_group: old_space_group
        )

        space.update(space_group: new_space_group)
      end

      def space_group_title(school_data)
        owner = school_data["ForeldreRelasjoner"].find { |r| r["Relasjonstype"]["Navn"] == "Eierstruktur" }
        return unless owner

        owner_title = owner["Enhet"]["Navn"] # E.g. "Oslo kommune"
        return unless owner_title

        "skoler eid av #{owner_title}"
      end

      def clean_up_unused_space_group(space_no_longer_belonging_to_space_group:, space_group:)
        return if space_group.blank?
        return if other_spaces_still_belong_to_space_group?(space_no_longer_belonging_to_space_group:, space_group:)
        return if space_contacts_still_belong_to_space_group?(space_group:)

        space_group.destroy
      end

      def space_contacts_still_belong_to_space_group?(space_group:)
        SpaceContact.where(space_group_id: space_group.id).any?
      end

      def other_spaces_still_belong_to_space_group?(space_no_longer_belonging_to_space_group:, space_group:)
        Space.where.not(id: space_no_longer_belonging_to_space_group.id).where(space_group_id: space_group.id).any?
      end
    end
  end
end
