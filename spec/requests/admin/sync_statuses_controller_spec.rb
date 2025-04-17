# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::SyncStatusesController, type: :request do
  let(:admin_user) { Fabricate(:user, admin: true) }
  let(:regular_user) { Fabricate(:user) }
  let!(:sync_status) { Fabricate(:sync_status) }
  let(:valid_attributes) do
    {
      source: "brreg",
      id_from_source: "123456789",
      last_attempted_sync_at: Time.current
    }
  end
  let(:invalid_attributes) do
    {
      source: nil,
      id_from_source: nil
    }
  end
  let(:new_attributes) do
    {
      source: "nsr",
      error_message: "New error message"
    }
  end

  describe "admin access" do
    before { sign_in admin_user }

    it "loads the index page" do
      get admin_sync_statuses_path
      expect(response).to have_http_status(:success)
    end

    it "loads the show page" do
      get admin_sync_status_path(sync_status)
      expect(response).to have_http_status(:success)
    end

    it "loads the new page" do
      get new_admin_sync_status_path
      expect(response).to have_http_status(:success)
    end

    it "loads the edit page" do
      get edit_admin_sync_status_path(sync_status)
      expect(response).to have_http_status(:success)
    end

    it "creates a new sync status with valid parameters" do
      expect do
        post admin_sync_statuses_path, params: { sync_status: valid_attributes }
      end.to change(Admin::SyncStatus, :count).by(1)

      expect(response).to redirect_to(Admin::SyncStatus.last)
    end

    it "doesn't create a sync status with invalid parameters" do
      expect do
        post admin_sync_statuses_path, params: { sync_status: invalid_attributes }
      end.not_to change(Admin::SyncStatus, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "updates a sync status with valid parameters" do
      patch admin_sync_status_path(sync_status), params: { sync_status: new_attributes }
      sync_status.reload
      expect(sync_status.source).to eq("nsr")
      expect(sync_status.error_message).to eq("New error message")
      expect(response).to redirect_to(sync_status)
    end

    it "doesn't update a sync status with invalid parameters" do
      patch admin_sync_status_path(sync_status), params: { sync_status: invalid_attributes }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "destroys a sync status" do
      expect do
        delete admin_sync_status_path(sync_status)
      end.to change(Admin::SyncStatus, :count).by(-1)

      expect(response).to redirect_to(admin_sync_statuses_path)
    end
  end

  describe "regular user access" do
    before { sign_in regular_user }

    it "redirects index to spaces path" do
      get admin_sync_statuses_path
      expect(response).to redirect_to(spaces_path)
    end

    it "redirects show to spaces path" do
      get admin_sync_status_path(sync_status)
      expect(response).to redirect_to(spaces_path)
    end

    it "redirects create to spaces path" do
      post admin_sync_statuses_path, params: { sync_status: valid_attributes }
      expect(response).to redirect_to(spaces_path)
    end
  end
end
