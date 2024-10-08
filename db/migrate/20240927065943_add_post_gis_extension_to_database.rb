class AddPostGisExtensionToDatabase < ActiveRecord::Migration[7.1]
  def change
    enable_extension 'postgis' unless extension_enabled? 'postgis'
  end
end
