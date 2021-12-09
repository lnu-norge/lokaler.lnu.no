# frozen_string_literal: true

class SpaceImagesController < AuthenticateController
  before_action :set_space

  def show; end

  def destroy
    @space.images.find(params[:image]).destroy!
    flash[:notice] = t("images.delete_success")
    redirect_to space_image_path(@space)
  end

  def upload_image
    params["image"].each do |image|
      Image.create!(space: @space, image: image)
    end
    flash[:notice] = t("images.upload_success")
    redirect_to space_path(params[:id])
  end

  def update
    @image = @space.images.find(params[:image_id])
    @image.update(image_params)
    redirect_to space_image_path(@space)
  end

  private

  def image_params
    params.require(:image).permit(:caption, :credits)
  end

  def set_space
    @space = Space.find(params[:id])
  end
end
