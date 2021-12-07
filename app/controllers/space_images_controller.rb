# frozen_string_literal: true

class SpaceImagesController < AuthenticateController
  before_action :set_space

  def show; end

  def destroy
    @image = ActiveStorage::Attachment.find(params[:image])
    @image.purge
    redirect_to space_image_path(@space)
  end

  def upload_image
    @space.images.attach(params[:image])
    @space.save!
    flash[:notice] = t("images.upload_success")
    redirect_to space_path(params[:id])
  end

  private

  def set_space
    @space = Space.find(params[:id])
  end
end
