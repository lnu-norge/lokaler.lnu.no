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
      it "loads the show page for a Space version" do
        space = Fabricate(:space)
        version = PaperTrail::Version.where(item_type: "Space", item_id: space.id).first

        get admin_history_path(version)
        expect(response).to have_http_status(:success)
      end

      it "loads the show page for a SpaceContact version" do
        space = Fabricate(:space)
        space_contact = Fabricate(:space_contact, space: space)
        version = PaperTrail::Version.where(item_type: "SpaceContact", item_id: space_contact.id).first

        get admin_history_path(version)
        expect(response).to have_http_status(:success)
      end

      it "loads the show page for a Review version" do
        space = Fabricate(:space)
        review = Fabricate(:review, space: space, user: admin_user)
        version = PaperTrail::Version.where(item_type: "Review", item_id: review.id).first

        get admin_history_path(version)
        expect(response).to have_http_status(:success)
      end

      it "loads the show page for a SpaceGroup version" do
        space_group = Fabricate(:space_group)
        version = PaperTrail::Version.where(item_type: "SpaceGroup", item_id: space_group.id).first

        get admin_history_path(version)
        expect(response).to have_http_status(:success)
      end

      it "loads the show page for a SpaceGroup update version" do
        space_group = Fabricate(:space_group, title: "Original title")
        # Create an update to generate a second version
        space_group.update!(title: "Updated title")

        # Get the second version (the update)
        version = PaperTrail::Version.where(item_type: "SpaceGroup", item_id: space_group.id, event: "update").first

        get admin_history_path(version)
        expect(response).to have_http_status(:success)
      end

      it "loads the show page for an ActionText::RichText version related to Space" do
        space = Fabricate(:space)
        space.update(how_to_book: ActionText::Content.new("Test rich text content"))
        rich_text = space.rich_text_how_to_book
        version = PaperTrail::Version.where(item_type: "ActionText::RichText", item_id: rich_text.id).first

        get admin_history_path(version)
        expect(response).to have_http_status(:success)
      end

      it "loads the show page for an ActionText::RichText version related to SpaceGroup" do
        space_group = Fabricate(:space_group)
        space_group.update(how_to_book: ActionText::Content.new("Test space group rich text content"))
        rich_text = space_group.rich_text_how_to_book
        version = PaperTrail::Version.where(item_type: "ActionText::RichText", item_id: rich_text.id).first

        get admin_history_path(version)
        expect(response).to have_http_status(:success)
      end

      it "gracefully handles viewing history for models that no longer exist" do
        # Use SQL to insert a version record directly, bypassing model validations
        now = Time.current
        ActiveRecord::Base.connection.execute(
          "INSERT INTO versions (item_type, item_id, event, whodunnit, created_at) " \
          "VALUES ('SpaceOwner', 123, 'create', '#{admin_user.id}', '#{now}')"
        )
        version = PaperTrail::Version.where(item_type: "SpaceOwner", item_id: 123).first
        # We already have the version

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
      it "redirects to spaces path for a Space version" do
        space = Fabricate(:space)
        version = PaperTrail::Version.where(item_type: "Space", item_id: space.id).first

        get admin_history_path(version)
        expect(response).to redirect_to(spaces_path)
      end

      it "redirects to spaces path for a SpaceContact version" do
        space = Fabricate(:space)
        space_contact = Fabricate(:space_contact, space: space)
        version = PaperTrail::Version.where(item_type: "SpaceContact", item_id: space_contact.id).first

        get admin_history_path(version)
        expect(response).to redirect_to(spaces_path)
      end
    end
  end
end
