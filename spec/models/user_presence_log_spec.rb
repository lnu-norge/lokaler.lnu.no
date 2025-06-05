# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPresenceLog, type: :model do
  let(:user) { Fabricate(:user) }

  describe "validations" do
    it "validates presence of required fields" do
      log = described_class.new
      expect(log).not_to be_valid
      expect(log.errors[:user]).to include("må eksistere")
      expect(log.errors[:date]).to include("kan ikke være tom")
    end

    it "validates uniqueness of user_id scoped to date" do
      described_class.create!(user: user, date: Date.current)

      duplicate_log = described_class.new(user: user, date: Date.current)
      expect(duplicate_log).not_to be_valid
      expect(duplicate_log.errors[:user_id]).to include("er allerede i bruk")
    end

    it "allows same user on different dates" do
      described_class.create!(user: user, date: Date.current)

      different_date_log = described_class.new(user: user, date: Date.current - 1.day)
      expect(different_date_log).to be_valid
    end

    it "allows different users on same date" do
      other_user = Fabricate(:user)
      described_class.create!(user: user, date: Date.current)

      different_user_log = described_class.new(user: other_user, date: Date.current)
      expect(different_user_log).to be_valid
    end
  end

  describe "associations" do
    it "belongs to user" do
      log = described_class.new(user: user, date: Date.current)
      expect(log.user).to eq(user)
    end

    it "requires a user" do
      log = described_class.new(user: nil, date: Date.current)
      expect(log).not_to be_valid
    end
  end

  describe "scopes" do
    before do
      # Create test data
      Fabricate(:user_presence_log, user: user, date: 3.days.ago)
      Fabricate(:user_presence_log, user: user, date: 2.days.ago)
      Fabricate(:user_presence_log, user: user, date: 1.day.ago)
      Fabricate(:user_presence_log, user: user, date: Date.current)
    end

    describe ".recent" do
      it "orders by date descending" do
        recent_logs = described_class.recent
        dates = recent_logs.pluck(:date)
        expect(dates).to eq(dates.sort.reverse)
      end
    end

    describe ".for_date" do
      it "filters by specific date" do
        logs = described_class.for_date(Date.current)
        expect(logs.count).to eq(1)
        expect(logs.first.date).to eq(Date.current)
      end
    end

    describe ".since" do
      it "filters logs since a specific date" do
        logs = described_class.since(2.days.ago)
        expect(logs.count).to eq(3) # 2 days ago, 1 day ago, today
      end
    end

    describe ".between" do
      it "filters logs between two dates" do
        logs = described_class.between(2.days.ago, Date.current)
        expect(logs.count).to eq(3) # 2 days ago, 1 day ago, today
      end

      it "handles single day range" do
        logs = described_class.between(Date.current, Date.current)
        expect(logs.count).to eq(1)
      end
    end
  end

  describe ".log_user_presence" do
    context "when no existing log for user and date" do
      it "creates a new presence log" do
        expect do
          described_class.log_user_presence(user, Date.current)
        end.to change(described_class, :count).by(1)

        log = described_class.last
        expect(log.user).to eq(user)
        expect(log.date).to eq(Date.current)
      end
    end

    context "when existing log for user and date" do
      before do
        described_class.create!(user: user, date: Date.current)
      end

      it "does not create a duplicate log" do
        expect do
          described_class.log_user_presence(user, Date.current)
        end.not_to change(described_class, :count)
      end

      it "returns the existing log" do
        existing_log = described_class.find_by(user: user, date: Date.current)
        result = described_class.log_user_presence(user, Date.current)
        expect(result).to eq(existing_log)
      end
    end

    context "when date is not provided" do
      it "defaults to current date" do
        log = described_class.log_user_presence(user)
        expect(log.date).to eq(Date.current)
      end
    end

    context "with different users" do
      let(:other_user) { Fabricate(:user) }

      it "creates separate logs for different users on same date" do
        described_class.log_user_presence(user, Date.current)
        described_class.log_user_presence(other_user, Date.current)

        expect(described_class.for_date(Date.current).count).to eq(2)
        expect(described_class.where(user: user).count).to eq(1)
        expect(described_class.where(user: other_user).count).to eq(1)
      end
    end

    context "with different dates" do
      it "creates separate logs for same user on different dates" do
        described_class.log_user_presence(user, Date.current)
        described_class.log_user_presence(user, Date.current - 1.day)

        expect(described_class.where(user: user).count).to eq(2)
      end
    end
  end

  describe "daily activity tracking" do
    it "tracks user activity over multiple days" do
      dates = [3.days.ago.to_date, 2.days.ago.to_date, Date.current]

      dates.each do |date|
        described_class.log_user_presence(user, date)
      end

      user_activity = described_class.where(user: user).order(:date)
      expect(user_activity.count).to eq(3)
      expect(user_activity.pluck(:date)).to eq(dates.sort)
    end

    it "can determine active days for a user" do
      # User was active 5 days ago, 3 days ago, and today
      active_dates = [5.days.ago.to_date, 3.days.ago.to_date, Date.current]

      active_dates.each do |date|
        described_class.log_user_presence(user, date)
      end

      user_active_days = described_class.where(user: user).pluck(:date).sort
      expect(user_active_days).to eq(active_dates.sort)
    end

    it "can find users active on a specific date" do
      other_users = Fabricate.times(3, :user)
      active_date = Date.current

      # Log presence for main user and 2 of the other users
      described_class.log_user_presence(user, active_date)
      described_class.log_user_presence(other_users[0], active_date)
      described_class.log_user_presence(other_users[1], active_date)
      # other_users[2] was not active

      active_users = described_class.for_date(active_date)
                                    .joins(:user)
                                    .pluck("users.id")

      expect(active_users).to contain_exactly(user.id, other_users[0].id, other_users[1].id)
      expect(active_users).not_to include(other_users[2].id)
    end
  end
end
