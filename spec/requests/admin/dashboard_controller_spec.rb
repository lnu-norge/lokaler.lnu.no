# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Dashboard", type: :request do
  let(:admin_user) { Fabricate(:user, admin: true) }
  let(:regular_user) { Fabricate(:user) }

  describe "as an admin user" do
    before do
      sign_in admin_user

      # Create some test data to prevent SQL error in dashboard with empty data
      Fabricate(:user, organization_name: "Organization 1")
      Fabricate(:user, organization_name: "Organization 2")
    end

    describe "GET /admin/dashboard" do
      it "loads the index page" do
        get admin_dashboard_index_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "as a regular user" do
    before do
      sign_in regular_user
    end

    describe "GET /admin/dashboard" do
      it "redirects to spaces path" do
        get admin_dashboard_index_path
        expect(response).to redirect_to(spaces_path)
      end
    end
  end
end
