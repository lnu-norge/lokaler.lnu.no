# frozen_string_literal: true

class Image < ApplicationRecord
  has_one_attached :image
  belongs_to :space

  before_destroy :delete_image

  def url
    Rails.application.routes.url_helpers.url_for(image)
  end

  private

  def delete_image
    image.purge
  end
end
