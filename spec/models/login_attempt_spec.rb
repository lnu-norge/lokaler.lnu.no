# frozen_string_literal: true

require "rails_helper"

RSpec.describe LoginAttempt, type: :model do
  let(:user) { Fabricate(:user) }

  describe "validations" do
    it "validates presence of required fields" do
      attempt = described_class.new
      expect(attempt).not_to be_valid
      expect(attempt.errors[:identifier]).to include("kan ikke være tom")
      expect(attempt.errors[:login_method]).to include("kan ikke være tom")
      # Status has a default value so it won't be blank
    end
  end

  describe "associations" do
    it "belongs to user optionally" do
      attempt = described_class.new(
        user: nil,
        identifier: "foobar",
        login_method: "magic_link",
        status: "pending"
      )
      expect(attempt).to be_valid
    end

    it "can belong to a user" do
      attempt = described_class.new(
        user: user,
        identifier: "foobar",
        login_method: "magic_link",
        status: "successful"
      )
      expect(attempt).to be_valid
      expect(attempt.user).to eq(user)
    end
  end

  describe "enums" do
    describe "login_method" do
      it "supports magic_link" do
        attempt = Fabricate(:login_attempt, login_method: "magic_link")
        expect(attempt.magic_link?).to be true
        expect(attempt.login_method).to eq("magic_link")
      end

      it "supports google_oauth" do
        attempt = Fabricate(:login_attempt, login_method: "google_oauth")
        expect(attempt.google_oauth?).to be true
        expect(attempt.login_method).to eq("google_oauth")
      end
    end

    describe "status" do
      it "supports pending status" do
        attempt = Fabricate(:login_attempt, status: "pending")
        expect(attempt.pending?).to be true
        expect(attempt.status).to eq("pending")
      end

      it "supports successful status" do
        attempt = Fabricate(:login_attempt, status: "successful")
        expect(attempt.successful?).to be true
        expect(attempt.status).to eq("successful")
      end

      it "supports failed status" do
        attempt = Fabricate(:login_attempt, status: "failed")
        expect(attempt.failed?).to be true
        expect(attempt.status).to eq("failed")
      end

      it "defaults to pending" do
        attempt = described_class.new(
          login_method: "magic_link"
        )
        expect(attempt.status).to eq("pending")
      end
    end
  end

  describe "scopes" do
    before do
      Fabricate(:login_attempt, status: "pending", created_at: 1.hour.ago)
      Fabricate(:login_attempt, status: "successful", created_at: 30.minutes.ago)
      Fabricate(:login_attempt, status: "failed", created_at: 15.minutes.ago)
    end

    it "filters by status" do
      expect(described_class.pending.count).to eq(1) # One from before block + default status
      expect(described_class.successful.count).to eq(1)
      expect(described_class.failed.count).to eq(1)
    end

    it "orders by recent" do
      recent_attempts = described_class.recent
      expect(recent_attempts.first.created_at).to be > recent_attempts.last.created_at
    end

    it "filters since a date" do
      attempts = described_class.since(45.minutes.ago)
      expect(attempts.count).to eq(2) # Last 2 attempts
    end
  end
end
