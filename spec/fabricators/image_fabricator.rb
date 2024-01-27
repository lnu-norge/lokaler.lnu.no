# frozen_string_literal: true

Fabricator(:image) do
  space
  image { Rack::Test::UploadedFile.new(TestImageHelper.image_path, TestImageHelper.content_type) }
end
