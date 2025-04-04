# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

RSpec.describe SyncingData::Shared::SafelySyncDataService do
  let(:user_or_robot_doing_the_syncing) { Fabricate(:robot) }
  let(:space) { Fabricate(:space) }
  let(:field) { :how_to_book }
  let(:first_change_to_data) { "<p>New data on how to book!</p>" }
  let(:second_change_to_data) { "<p>Changed data on how to book!</p>" }
  let(:human_change_to_data) { "<p>A human wrote this</p>" }
  let(:unknown_originator_to_data) { "<p>Unknown originator wrote this</p>" }
  let(:new_data) { first_change_to_data }
  let(:service_proposing_first_change_to_data) do
    described_class.new(
      user_or_robot_doing_the_syncing:,
      model: space,
      field:,
      new_data:
    )
  end

  describe "handles different fields and models" do
    it "when field is directly on the model" do
      space.update!(title: "Old title")
      described_class.new(
        user_or_robot_doing_the_syncing:,
        model: space,
        field: :title,
        new_data: "New title"
      ).safely_sync_data
      expect(space.reload.title).to eq("New title")
    end

    it "when field is RichText or otherwise related to model" do
      space.update!(how_to_book: first_change_to_data)
      described_class.new(
        user_or_robot_doing_the_syncing:,
        model: space,
        field: :how_to_book,
        new_data: second_change_to_data
      ).safely_sync_data
      expect(space.reload.how_to_book.to_s).to include(second_change_to_data)
    end
  end

  describe "writes new data" do
    it "when there is no existing data" do
      # Expect the field to be empty
      expect(space.reload.how_to_book).to be_blank

      expect(service_proposing_first_change_to_data.should_sync_be_allowed?).to be(true)

      service_proposing_first_change_to_data.safely_sync_data

      # Expect the field to have the new data
      expect(space.reload.how_to_book.to_s).to include(new_data)
    end

    it "with paper trail versioning" do
      # Expect there to be no versions for the field
      expect(space.how_to_book.versions.count).to eq(0)

      service_proposing_first_change_to_data.safely_sync_data

      # Expect there to be one version for the field, with the user as whodunnit
      expect(space.how_to_book.versions.count).to eq(1)
      expect(space.how_to_book.versions.first.whodunnit).to eq(user_or_robot_doing_the_syncing.id.to_s)
    end

    it "when the current data was set by the same user" do
      service_proposing_first_change_to_data.safely_sync_data
      expect(space.reload.how_to_book.to_s).to include(first_change_to_data)

      described_class.new(
        user_or_robot_doing_the_syncing:,
        model: space,
        field:,
        new_data: second_change_to_data
      ).safely_sync_data

      expect(space.reload.how_to_book.to_s).not_to include(first_change_to_data)
      expect(space.reload.how_to_book.to_s).to include(second_change_to_data)
    end

    it "when the current data was set without a whodunnit (probably by a seed, migration, or rails console)" do
      PaperTrail.request(whodunnit: nil) do
        space.update!(how_to_book: unknown_originator_to_data)
      end
      expect(space.reload.how_to_book).not_to be_blank

      service_proposing_first_change_to_data.safely_sync_data

      expect(space.reload.how_to_book.to_s).to include(first_change_to_data)
      expect(space.reload.how_to_book.to_s).not_to include(unknown_originator_to_data)
    end

    it "when the current data has no version logged at all (probably set by seed)" do
      PaperTrail.request(enabled: false) do
        space.update!(how_to_book: unknown_originator_to_data)
      end
      expect(space.reload.how_to_book).not_to be_blank

      service_proposing_first_change_to_data.safely_sync_data

      expect(space.reload.how_to_book.to_s).to include(first_change_to_data)
      expect(space.reload.how_to_book.to_s).not_to include(unknown_originator_to_data)
    end
  end

  describe "does not write new data" do
    it "when the same data is already present" do
      space.update!(how_to_book: first_change_to_data)
      expect(space.how_to_book.versions.count).to eq(1)
      expect(service_proposing_first_change_to_data.should_sync_be_allowed?).to be(false)
      service_proposing_first_change_to_data.safely_sync_data
      expect(space.reload.how_to_book.to_s).to include(first_change_to_data)
      expect(space.how_to_book.versions.count).to eq(1)
    end

    it "when there is existing data added by a human user" do
      human_user = Fabricate(:user)
      PaperTrail.request(whodunnit: human_user.id) do
        space.update!(how_to_book: human_change_to_data)
      end
      expect(space.reload.how_to_book).not_to be_blank

      service_proposing_first_change_to_data.safely_sync_data

      expect(space.reload.how_to_book.to_s).not_to include(first_change_to_data)
      expect(space.reload.how_to_book.to_s).to include(human_change_to_data)
    end

    it "when the proposed data for rich text has been overwritten before" do
      space.update!(how_to_book: first_change_to_data)
      space.update!(how_to_book: second_change_to_data)

      service_proposing_first_change_to_data.safely_sync_data

      expect(space.reload.how_to_book.body.to_html).not_to include(first_change_to_data)
      expect(space.reload.how_to_book.body.to_html).to include(second_change_to_data)
    end

    it "when the proposed data for a regular field has been overwritten before" do
      space.update!(title: "Old title")
      space.update!(title: "New title")

      described_class.new(
        user_or_robot_doing_the_syncing:,
        model: space,
        field: :title,
        new_data: "Old title"
      )

      expect(space.reload.title).not_to eq("Old title")
      expect(space.reload.title).to eq("New title")
    end
  end
end
