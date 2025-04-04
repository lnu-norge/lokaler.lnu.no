# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

RSpec.shared_examples "a safely sync data service" do | # rubocop:disable Metrics/ParameterLists
    model_type:,
    field:,
    first_change_to_data:,
    second_change_to_data:,
    human_change_to_data:,
    unknown_originator_to_data:,
    empty_data: ""
|
  let(:user_or_robot_doing_the_syncing) { Fabricate(:robot) }
  let(:model) { Fabricate(model_type) }
  let(:new_data) { first_change_to_data }
  let(:service_proposing_first_change_to_data) do
    described_class.new(
      user_or_robot_doing_the_syncing:,
      model: model,
      field:,
      new_data:
    )
  end
  let(:versions) do
    case model.public_send(field).class.name
    when "ActionText::RichText"
      model.public_send(field).versions
    else
      model.versions
    end
  end

  let(:stored_data) do
    reloaded_stored_data(model, field)
  end

  def reloaded_stored_data(model, field)
    case model.public_send(field).class.name
    when "ActionText::RichText"
      model.reload.public_send(field)&.reload&.body&.to_html # rubocop:disable Style/SafeNavigationChainLength
    else
      model.public_send(field)
    end
  end

  describe "writes new data" do
    it "when there is no existing data" do
      # Only run test if the field is empty. Some fields are not empty by default
      next if model.public_send(field).present?

      expect(service_proposing_first_change_to_data.should_sync_be_allowed?).to be(true)

      service_proposing_first_change_to_data.safely_sync_data

      # Expect the field to have the new data
      expect(stored_data).to include(new_data)
    end

    it "with paper trail versioning" do
      expect do
        service_proposing_first_change_to_data.safely_sync_data
      end.to change(versions, :count).by(1)

      expect(versions.last.whodunnit).to eq(user_or_robot_doing_the_syncing.id.to_s)
    end

    it "when the current data was set by the same user" do
      service_proposing_first_change_to_data.safely_sync_data
      expect(stored_data).to eq(first_change_to_data)

      described_class.new(
        user_or_robot_doing_the_syncing:,
        model: model,
        field:,
        new_data: second_change_to_data
      ).safely_sync_data

      stored_data = reloaded_stored_data(model, field)
      expect(stored_data).not_to eq(first_change_to_data)
      expect(stored_data).to eq(second_change_to_data)
    end

    it "when the current data was set without a whodunnit (probably by a seed, migration, or rails console)" do
      PaperTrail.request(whodunnit: nil) do
        model.update!(field => unknown_originator_to_data)
      end
      expect(stored_data).not_to be_blank

      service_proposing_first_change_to_data.safely_sync_data

      stored_data = reloaded_stored_data(model, field)
      expect(stored_data).to eq(first_change_to_data)
      expect(stored_data).not_to eq(unknown_originator_to_data)
    end

    it "when the current data has no version logged at all (probably set by seed)" do
      PaperTrail.request(enabled: false) do
        model.update!(field => unknown_originator_to_data)
      end
      expect(stored_data).not_to be_blank

      service_proposing_first_change_to_data.safely_sync_data

      stored_data = reloaded_stored_data(model, field)
      expect(stored_data).to eq(first_change_to_data)
      expect(stored_data).not_to eq(unknown_originator_to_data)
    end

    it "when the new data is empty and we pass a flag to allow empty new data" do
      model.update!(field => first_change_to_data)

      begin
        described_class.new(
          user_or_robot_doing_the_syncing:,
          model: model,
          field:,
          new_data: empty_data,
          allow_empty_new_data: true
        ).safely_sync_data

        expect(stored_data).to eq(empty_data)
      rescue ActiveRecord::RecordInvalid
        # Record might be invalid if field can't be empty,
        # still means the sync was attempted.
        expect(model.errors[:"#{field}"]).to be_present
      end
    end
  end

  describe "does not write new data" do
    it "when the same data is already present" do
      model.update!(field => first_change_to_data)
      expect(service_proposing_first_change_to_data.should_sync_be_allowed?).to be(false)
      expect do
        service_proposing_first_change_to_data.safely_sync_data
      end.not_to change(versions, :count)
      expect(stored_data).to eq(first_change_to_data)
    end

    it "when there is existing data added by a human user" do
      human_user = Fabricate(:user)
      PaperTrail.request(whodunnit: human_user.id) do
        model.update!(field => human_change_to_data)
      end
      expect(stored_data).not_to be_blank

      service_proposing_first_change_to_data.safely_sync_data

      expect(stored_data).not_to eq(first_change_to_data)
      expect(stored_data).to eq(human_change_to_data)
    end

    it "when the proposed data has been overwritten before" do
      model.update!(field => first_change_to_data)
      model.update!(field => second_change_to_data)

      service_proposing_first_change_to_data.safely_sync_data

      expect(stored_data).not_to eq(first_change_to_data)
      expect(stored_data).to eq(second_change_to_data)
    end

    it "when the new data is empty" do
      model.update!(field => first_change_to_data)

      described_class.new(
        user_or_robot_doing_the_syncing:,
        model: model,
        field:,
        new_data: empty_data
      ).safely_sync_data

      expect(stored_data).to eq(first_change_to_data)
    end
  end
end

RSpec.describe SyncingData::Shared::SafelySyncDataService do
  context "with rich text" do
    it_behaves_like "a safely sync data service",
                    model_type: :space,
                    field: :how_to_book,
                    first_change_to_data: "<p>New data on how to book!</p>",
                    second_change_to_data: "<p>Changed data on how to book!</p>",
                    human_change_to_data: "<p>A human wrote this</p>",
                    unknown_originator_to_data: "<p>Unknown originator wrote this</p>"
  end

  context "with a string field" do
    it_behaves_like "a safely sync data service",
                    model_type: :space,
                    field: :title,
                    first_change_to_data: "New title!",
                    second_change_to_data: "Changed title!",
                    human_change_to_data: "Human wrote this title!",
                    unknown_originator_to_data: "Unknown originator wrote this title!"
  end

  context "with a space contact" do
    it_behaves_like "a safely sync data service",
                    model_type: :space_contact,
                    field: :url,
                    first_change_to_data: "https://example.com/first",
                    second_change_to_data: "https://example.com/second",
                    human_change_to_data: "https://example.com/human",
                    unknown_originator_to_data: "https://example.com/unknown"
  end

  context "with a relationship" do
    it_behaves_like "a safely sync data service",
                    model_type: :space,
                    field: :space_group,
                    first_change_to_data: Fabricate(:space_group),
                    second_change_to_data: Fabricate(:space_group),
                    human_change_to_data: Fabricate(:space_group),
                    unknown_originator_to_data: Fabricate(:space_group),
                    empty_data: nil
  end

  context "with a relationship set by id" do
    it_behaves_like "a safely sync data service",
                    model_type: :space,
                    field: :space_group_id,
                    first_change_to_data: Fabricate(:space_group).id,
                    second_change_to_data: Fabricate(:space_group).id,
                    human_change_to_data: Fabricate(:space_group).id,
                    unknown_originator_to_data: Fabricate(:space_group).id,
                    empty_data: nil
  end

  # TODO: It currently fails for a many-to-many relationship, because
  # paper trail does not track it. I have attempted to do so using this plugin
  # but could not figure it out yet. https://github.com/westonganger/paper_trail-association_tracking
  #
  # context "with a many-to-many relationship" do
  #   it_behaves_like "a safely sync data service",
  #                model_type: :space,
  #                field: :space_types,
  #                first_change_to_data: [Fabricate(:space_type), Fabricate(:space_type)],
  #                second_change_to_data: [Fabricate(:space_type), Fabricate(:space_type)],
  #                human_change_to_data: [Fabricate(:space_type), Fabricate(:space_type)],
  #                 unknown_originator_to_data: [Fabricate(:space_type), Fabricate(:space_type)],
  #                empty_data: []
  # end
end
