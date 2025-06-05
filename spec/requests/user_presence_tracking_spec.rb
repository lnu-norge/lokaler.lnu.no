# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User Presence Tracking", type: :request do
  let(:user) { Fabricate(:user) }

  describe "automatic presence logging" do
    before do
      sign_in user
    end

    it "logs user presence when making authenticated requests" do
      expect do
        get root_path
      end.to change(UserPresenceLog, :count).by(1)

      presence_log = UserPresenceLog.last
      expect(presence_log.user).to eq(user)
      expect(presence_log.date).to eq(Date.current)
    end

    it "does not create duplicate presence logs for same user on same day" do
      # First request creates presence log
      get root_path
      expect(UserPresenceLog.count).to eq(1)

      # Second request on same day should not create another log
      expect do
        get root_path
      end.not_to change(UserPresenceLog, :count)

      # Still only one log for today
      expect(UserPresenceLog.where(user: user, date: Date.current).count).to eq(1)
    end

    it "creates presence logs for different days" do
      # Simulate presence log from yesterday
      UserPresenceLog.create!(user: user, date: Date.current - 1.day)

      # Today's request should create a new log
      expect do
        get root_path
      end.to change(UserPresenceLog, :count).by(1)

      # Should have logs for both days
      expect(UserPresenceLog.where(user: user).count).to eq(2)
      expect(UserPresenceLog.where(user: user, date: Date.current).count).to eq(1)
      expect(UserPresenceLog.where(user: user, date: Date.current - 1.day).count).to eq(1)
    end

    it "handles presence logging errors gracefully" do
      # Mock an error in presence logging
      allow(UserPresenceLog).to receive(:log_user_presence).and_raise(StandardError.new("Database error"))

      # Request should still succeed even if presence logging fails
      expect do
        get root_path
      end.not_to raise_error

      expect(response).to have_http_status(:success)
    end
  end

  describe "unauthenticated requests" do
    it "does not log presence for unauthenticated users" do
      expect do
        get unauthenticated_root_path
      end.not_to change(UserPresenceLog, :count)
    end
  end

  describe "multiple users" do
    let(:other_user) { Fabricate(:user) }

    it "logs presence for different users separately" do
      # First user makes request
      sign_in user
      get root_path
      sign_out user

      # Second user makes request
      sign_in other_user
      get root_path

      expect(UserPresenceLog.count).to eq(2)
      expect(UserPresenceLog.where(user: user, date: Date.current).count).to eq(1)
      expect(UserPresenceLog.where(user: other_user, date: Date.current).count).to eq(1)
    end
  end

  describe "across different controller actions" do
    before do
      sign_in user
    end

    it "logs presence for any authenticated controller action" do
      # Clear any existing presence logs
      UserPresenceLog.destroy_all

      # Make requests to different endpoints
      get root_path
      get personal_space_lists_path if respond_to?(:personal_space_lists_path)

      # Should only create one presence log per day regardless of number of requests
      expect(UserPresenceLog.where(user: user, date: Date.current).count).to eq(1)
    end
  end
end
