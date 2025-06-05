# frozen_string_literal: true

require "rails_helper"

RSpec.describe LoginAttempt, type: :model do
  let(:user) { Fabricate(:user) }

  describe "validations" do
    it "validates presence of required fields" do
      attempt = described_class.new
      expect(attempt).not_to be_valid
      expect(attempt.errors[:email]).to include("kan ikke være tom")
      expect(attempt.errors[:login_method]).to include("kan ikke være tom")
      # Status has a default value so it won't be blank
    end

    it "validates email format" do
      attempt = described_class.new(email: "invalid-email")
      expect(attempt).not_to be_valid
      expect(attempt.errors[:email]).to include("er ugyldig")
    end

    it "allows valid email formats" do
      attempt = described_class.new(
        email: "user@example.com",
        login_method: "magic_link",
        status: "pending"
      )
      expect(attempt).to be_valid
    end
  end

  describe "associations" do
    it "belongs to user optionally" do
      attempt = described_class.new(
        user: nil,
        email: "user@example.com",
        login_method: "magic_link",
        status: "pending"
      )
      expect(attempt).to be_valid
    end

    it "can belong to a user" do
      attempt = described_class.new(
        user: user,
        email: user.email,
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
          email: "user@example.com",
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
      Fabricate(:login_attempt, email: "test@example.com", created_at: 5.minutes.ago)
    end

    it "filters by status" do
      expect(described_class.pending.count).to eq(2) # One from before block + default status
      expect(described_class.successful.count).to eq(1)
      expect(described_class.failed.count).to eq(1)
    end

    it "orders by recent" do
      recent_attempts = described_class.recent
      expect(recent_attempts.first.created_at).to be > recent_attempts.last.created_at
    end

    it "filters by email" do
      attempts = described_class.for_email("test@example.com")
      expect(attempts.count).to eq(1)
    end

    it "filters since a date" do
      attempts = described_class.since(45.minutes.ago)
      expect(attempts.count).to eq(3) # Last 3 attempts
    end
  end

  describe "complete login flow" do
    it "tracks magic link request to completion" do
      email = user.email

      # Step 1: User requests magic link (pending)
      request_attempt = described_class.create!(
        user: user,
        email: email,
        status: "pending",
        login_method: "magic_link"
      )

      expect(request_attempt.pending?).to be true
      expect(described_class.pending.count).to eq(1)

      # Step 2: User successfully uses magic link
      success_attempt = described_class.create!(
        user: user,
        email: email,
        status: "successful",
        login_method: "magic_link"
      )

      expect(success_attempt.successful?).to be true
      expect(described_class.successful.count).to eq(1)
      expect(described_class.for_email(email).count).to eq(2)
    end

    it "tracks failed login attempts" do
      email = "nonexistent@example.com"

      failed_attempt = described_class.create!(
        user: nil,
        email: email,
        status: "failed",
        login_method: "magic_link",
        failed_reason: "Invalid token"
      )

      expect(failed_attempt.failed?).to be true
      expect(failed_attempt.failed_reason).to eq("Invalid token")
      expect(described_class.failed.count).to eq(1)
    end
  end
end
