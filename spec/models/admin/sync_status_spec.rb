# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::SyncStatus, type: :model do
  let(:source) { "nsr" }
  let(:id_from_source) { "id" }

  describe "validations" do
    it "requires a source and id_from_source" do
      sync_status = described_class.new(source: source)
      expect(sync_status).not_to be_valid

      sync_status.update(id_from_source: id_from_source)
      expect(sync_status).to be_valid

      sync_status.update(source: nil)
      expect(sync_status).not_to be_valid
    end

    it "enforces uniqueness of id_from_source and source" do
      # Create first sync status
      described_class.create!(source: source, id_from_source: "id")

      # Try to create a duplicate
      duplicate = described_class.new(source: source, id_from_source: "id")
      expect(duplicate).not_to be_valid
    end
  end

  describe ".for" do
    it "finds an existing sync status" do
      existing = described_class.create!(source: source, id_from_source: "id")
      found = described_class.for(source: source, id_from_source: "id")

      expect(found).to eq(existing)
      expect(found.persisted?).to be true
    end
  end

  describe "logging methods" do
    let(:sync_status) { described_class.create!(source: source, id_from_source: id_from_source) }

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
        end.to change { sync_status.reload.last_successful_sync_at }.to be_truthy
      end
    end

    describe "#log_failure" do
      it "sets the error message" do
        expect do
          sync_status.log_failure("Test error")
        end.to change { sync_status.reload.error_message }.to be_truthy
      end

      it "nils out the last_successful_sync_at" do
        sync_status.log_success
        expect(sync_status.reload.last_successful_sync_at).not_to be_nil

        sync_status.log_failure("Test error")
        expect(sync_status.reload.last_successful_sync_at).to be_nil
      end
    end
  end

  describe "database constraints" do
    it "prevents duplicate records at the database level" do
      # Create a sync status
      described_class.create!(source: source, id_from_source: id_from_source)

      # Try to insert a duplicate directly
      expect do
        ActiveRecord::Base.connection.execute(
          "INSERT INTO sync_statuses (source, id_from_source, created_at, updated_at)
          VALUES ('#{source}', '#{id_from_source}', NOW(), NOW())"
        )
      end.to raise_error(ActiveRecord::StatementInvalid, /duplicate key value violates unique constraint/)
    end
  end
end

# == Schema Information
#
# Table name: sync_statuses
#
#  id                      :bigint           not null, primary key
#  error_message           :string
#  full_error_message      :text
#  id_from_source          :string           not null
#  last_attempted_sync_at  :datetime
#  last_successful_sync_at :datetime
#  source                  :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_sync_statuses_on_id_from_source_and_source  (id_from_source,source) UNIQUE
#  index_sync_statuses_on_source                     (source)
#
