# frozen_string_literal: true

Fabricator(:image) do
  space
  after_create do |image|
    image.image.attach(TestImageHelper.image_upload)
  end
end
