# frozen_string_literal: true

module TestImageHelper
  def self.image_path
    Rails.root.join("spec/support/test_image/test_image.jpg")
  end

  def self.image_file
    File.open(image_path)
  end

  def self.image_upload
    {
      io: image_file,
      filename: "test_image.jpg",
      content_type: "image/jpeg"
    }
  end
end
