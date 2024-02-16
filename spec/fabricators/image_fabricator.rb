# frozen_string_literal: true

Fabricator(:image) do
  space
  image { Rack::Test::UploadedFile.new(TestImageHelper.image_path, TestImageHelper.content_type) }
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
