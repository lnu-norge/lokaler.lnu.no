# frozen_string_literal: true

require "rails_helper"

RSpec.describe SyncStatus, type: :model do
  let!(:space) { Fabricate(:space) }
  let(:source) { "nsr" }

  describe "validations" do
    it "requires a space" do
      sync_status = described_class.new(source: source)
      expect(sync_status).not_to be_valid
    end

    it "requires a source" do
      sync_status = described_class.new(space: space)
      expect(sync_status).not_to be_valid
    end

    it "enforces uniqueness of space_id and source" do
      # Create first sync status
      described_class.create!(space: space, source: source)

      # Try to create a duplicate
      duplicate = described_class.new(space: space, source: source)
      expect(duplicate).not_to be_valid
    end
  end

  describe ".for" do
    it "finds an existing sync status" do
      existing = described_class.create!(space: space, source: source)
      found = described_class.for(space: space, source: source)

      expect(found).to eq(existing)
      expect(found.persisted?).to be true
    end

    it "initializes a new sync status if none exists" do
      new_sync_status = described_class.for(space: space, source: "new_source")

      expect(new_sync_status.persisted?).to be false
      expect(new_sync_status.space).to eq(space)
      expect(new_sync_status.source).to eq("new_source")
    end
  end

  describe "logging methods" do
    let(:sync_status) { described_class.create!(space: space, source: source) }

    describe "#log_start" do
      it "updates last_attempted_sync_at timestamp" do
        expect do
          sync_status.log_start
        end.to(change { sync_status.reload.last_attempted_sync_at })
      end
    end

    describe "#log_success" do
      it "updates last_successful_sync_at timestamp and sets success flag" do
        expect do
          sync_status.log_success
        end.to change { sync_status.reload.last_successful_sync_at }
          .and change { sync_status.reload.last_attempt_was_successful }.to(true)
      end
    end

    describe "#log_failure" do
      it "sets the success flag to false" do
        expect do
          sync_status.log_failure
        end.to change { sync_status.reload.last_attempt_was_successful }.to(false)
      end
    end
  end

  describe "database constraints" do
    it "prevents duplicate records at the database level" do
      # Create a sync status
      described_class.create!(space: space, source: source)

      # Try to insert a duplicate directly
      expect do
        ActiveRecord::Base.connection.execute(
          "INSERT INTO sync_statuses (space_id, source, created_at, updated_at)
          VALUES (#{space.id}, '#{source}', NOW(), NOW())"
        )
      end.to raise_error(ActiveRecord::StatementInvalid, /duplicate key value violates unique constraint/)
    end
  end
end
