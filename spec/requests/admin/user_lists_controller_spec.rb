# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/NestedGroups
RSpec.describe "Admin::UserLists", type: :request do
  let(:admin_user) { Fabricate(:user, admin: true) }
  let(:regular_user) { Fabricate(:user) }

  describe "as an admin user" do
    before do
      sign_in admin_user
    end

    describe "GET /admin/user_lists" do
      before do
        Fabricate(:user, first_name: "John", last_name: "Doe", email: "john@example.com", organization_name: "Test Org")
        Fabricate(:robot, email: "robot@example.com")
        Fabricate(:user, admin: true, first_name: "Jane", last_name: "Admin")
      end

      it "loads the index page successfully" do
        get admin_user_lists_path
        expect(response).to have_http_status(:success)
      end

      it "displays all users" do
        get admin_user_lists_path
        expect(response.body).to include("John")
        expect(response.body).to include("robot@example.com")
        expect(response.body).to include("Jane")
      end

      context "with search filter" do
        it "filters users by search term" do
          get admin_user_lists_path, params: { search: "John" }
          expect(response).to have_http_status(:success)
        end
      end

      context "with type filter" do
        it "filters users by type - humans" do
          get admin_user_lists_path, params: { type: "humans" }
          expect(response).to have_http_status(:success)
        end

        it "filters users by type - robots" do
          get admin_user_lists_path, params: { type: "robots" }
          expect(response).to have_http_status(:success)
        end
      end

      context "with organization filter" do
        it "filters users by organization names" do
          get admin_user_lists_path, params: { organization_names: ["Test Org"] }
          expect(response).to have_http_status(:success)
        end
      end

      context "with admin filter" do
        it "filters users by admin status - true" do
          get admin_user_lists_path, params: { admin: "true" }
          expect(response).to have_http_status(:success)
        end

        it "filters users by admin status - false" do
          get admin_user_lists_path, params: { admin: "false" }
          expect(response).to have_http_status(:success)
        end
      end

      context "with date range filter" do
        it "filters users by start date" do
          get admin_user_lists_path, params: { start_date: 1.week.ago.to_date }
          expect(response).to have_http_status(:success)
        end

        it "filters users by end date" do
          get admin_user_lists_path, params: { end_date: Date.current }
          expect(response).to have_http_status(:success)
        end

        it "filters users by date range" do
          get admin_user_lists_path, params: {
            start_date: 1.week.ago.to_date,
            end_date: Date.current
          }
          expect(response).to have_http_status(:success)
        end
      end

      context "with sorting" do
        it "sorts users by name" do
          get admin_user_lists_path, params: { sort_by: "name", sort_direction: "asc" }
          expect(response).to have_http_status(:success)
        end

        it "sorts users by email" do
          get admin_user_lists_path, params: { sort_by: "email", sort_direction: "desc" }
          expect(response).to have_http_status(:success)
        end

        it "sorts users by organization" do
          get admin_user_lists_path, params: { sort_by: "organization", sort_direction: "asc" }
          expect(response).to have_http_status(:success)
        end

        it "sorts users by type" do
          get admin_user_lists_path, params: { sort_by: "type", sort_direction: "asc" }
          expect(response).to have_http_status(:success)
        end

        it "sorts users by admin status" do
          get admin_user_lists_path, params: { sort_by: "admin", sort_direction: "desc" }
          expect(response).to have_http_status(:success)
        end

        it "sorts users by created_at" do
          get admin_user_lists_path, params: { sort_by: "created_at", sort_direction: "desc" }
          expect(response).to have_http_status(:success)
        end

        it "sorts users by edit count" do
          get admin_user_lists_path, params: { sort_by: "edits", sort_direction: "desc" }
          expect(response).to have_http_status(:success)
        end

        it "sorts users by last edit date" do
          get admin_user_lists_path, params: { sort_by: "last_edit", sort_direction: "desc" }
          expect(response).to have_http_status(:success)
        end

        it "sorts users by space lists count" do
          get admin_user_lists_path, params: { sort_by: "space_lists", sort_direction: "desc" }
          expect(response).to have_http_status(:success)
        end
      end

      context "when exporting CSV" do
        it "exports users to CSV" do
          get admin_user_lists_path(format: :csv)
          expect(response).to have_http_status(:success)
          expect(response.content_type).to eq("text/csv")
          expect(response.headers["Content-Disposition"]).to include("users-#{Date.current}.csv")
        end

        it "exports filtered users to CSV" do
          get admin_user_lists_path(format: :csv, params: { search: "John" })
          expect(response).to have_http_status(:success)
          expect(response.content_type).to eq("text/csv")
        end

        it "includes proper CSV headers" do
          get admin_user_lists_path(format: :csv)
          csv_content = response.body
          # rubocop:disable Layout/LineLength
          expected_headers = "ID,Navn,Fornavn,Etternavn,E-post,Organisasjon,Type,Admin,Endringer,Siste endring,Lister,Opprettet,Sist oppdatert"
          # rubocop:enable Layout/LineLength
          expect(csv_content).to include(expected_headers)
        end

        it "includes user data in CSV" do
          get admin_user_lists_path(format: :csv)
          csv_content = response.body
          expect(csv_content).to include("john@example.com")
          expect(csv_content).to include("Test Org")
        end
      end

      context "with pagination" do
        it "paginates results" do
          get admin_user_lists_path, params: { page: 1 }
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe "as a regular user" do
    before do
      sign_in regular_user
    end

    describe "GET /admin/user_lists" do
      it "redirects to unauthorized" do
        get admin_user_lists_path
        expect(response).to have_http_status(:redirect)
      end
    end

    describe "CSV export as regular user" do
      it "redirects to unauthorized" do
        get admin_user_lists_path(format: :csv)
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "as unauthenticated user" do
    describe "GET /admin/user_lists" do
      it "redirects to sign in" do
        get admin_user_lists_path
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups
