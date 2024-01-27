# frozen_string_literal: true

class SpaceImagesController < BaseControllers::AuthenticateController
  before_action :set_space

  def show; end

  def update
    @image = @space.images.find(params[:image_id])
    @image.update(image_params)
    flash[:notice] = t("images.update_success")
    redirect_to space_image_path(@space)
  end

  def destroy
    @space.images.find(params[:image]).destroy!
    flash[:notice] = t("images.delete_success")
    redirect_to space_image_path(@space)
  end

  def upload_image
    images = params["images_to_upload"]&.compact_blank
    return upload_failed if images.blank?

    # Attempt to upload each image
    images.each do |image|
      new_image = Image.new(space: @space, image:)

      return upload_failed unless new_image.save
    end

    flash[:notice] = t("images.upload_success")
    redirect_to space_path(params[:id])
  end

  private

  def image_params
    params.require(:image).permit(:caption, :credits)
  end

  def set_space
    @space = Space.find(params[:id])
  end

  def upload_failed
    flash[:alert] = t("images.upload_failed")
    redirect_to space_path(params[:id])
  end
end
