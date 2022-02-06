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

# == Schema Information
#
# Table name: images
#
#  id         :bigint           not null, primary key
#  caption    :string
#  credits    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  space_id   :bigint
#
# Indexes
#
#  index_images_on_space_id  (space_id)
#
