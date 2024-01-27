# frozen_string_literal: true

require "rails_helper"

RSpec.describe "SpaceImages", type: :request do
  let(:user) { Fabricate(:user) }

  before do
    sign_in user
  end

  describe "POST /spaces/:id/upload_image" do
    let(:space) { Fabricate(:space) }
    let(:image_file) { fixture_file_upload(TestImageHelper.image_path, TestImageHelper.content_type) }

    it "fails to upload an empty image" do
      expect do
        post spaces_upload_image_path(id: space.id), params: { image: [""] }
      end.not_to change(space.images, :count)
      expect(response).to redirect_to(space_path(space.id))
      follow_redirect!
      expect(response.body).to include(I18n.t("images.upload_failed"))
    end

    it "uploads an image and redirects" do
      expect do
        # Rails for some reason adds an empty "" to the start of the array when allowing multiple uploads
        post spaces_upload_image_path(id: space.id), params: { images_to_upload: ["", image_file] }
      end.to change(space.images, :count).by(1)
      expect(response).to redirect_to(space_path(space.id))
      follow_redirect!
      expect(response.body).to include(I18n.t("images.upload_success"))
    end
  end

  describe "PUT /spaces/:id/images/:image_id" do
    let(:space) { Fabricate(:space) }
    let(:image) { Fabricate(:image, space:) }
    let(:params) { { image: { caption: "New Caption", credits: "New Credits" } } }

    it "updates the image info and redirects" do
      put(space_image_path(id: space.id, image_id: image.id), params:)
      expect(response).to redirect_to(space_image_path(space))
      follow_redirect!
      expect(response.body).to include(I18n.t("images.update_success"))
    end
  end

  describe "DELETE /spaces/:id/images/:image_id" do
    let(:space) { Fabricate(:space) }
    let!(:image) { Fabricate(:image, space:) }

    it "deletes the image and redirects" do
      expect { delete space_image_path(id: space.id, image:) }.to change(Image, :count).by(-1)
      expect(response).to redirect_to(space_image_path(space))
      follow_redirect!
      expect(response.body).to include(I18n.t("images.delete_success"))
    end
  end
end
