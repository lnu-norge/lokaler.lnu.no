# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::History", type: :request do
  let(:admin_user) { Fabricate(:user, admin: true) }
  let(:regular_user) { Fabricate(:user) }

  describe "as an admin user" do
    before do
      sign_in admin_user
    end

    describe "GET /admin/history" do
      it "loads the index page" do
        get admin_history_index_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /admin/history/:id" do
      it "loads the show page for a specific version" do
        # Create a space to generate a version
        space = Fabricate(:space)
        # Find the version created
        version = PaperTrail::Version.where(item_type: "Space", item_id: space.id).first

        get admin_history_path(version)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "as a regular user" do
    before do
      sign_in regular_user
    end

    describe "GET /admin/history" do
      it "redirects to spaces path" do
        get admin_history_index_path
        expect(response).to redirect_to(spaces_path)
      end
    end

    describe "GET /admin/history/:id" do
      it "redirects to spaces path" do
        # Create a space to generate a version
        space = Fabricate(:space)
        # Find the version created
        version = PaperTrail::Version.where(item_type: "Space", item_id: space.id).first

        get admin_history_path(version)
        expect(response).to redirect_to(spaces_path)
      end
    end
  end
end
