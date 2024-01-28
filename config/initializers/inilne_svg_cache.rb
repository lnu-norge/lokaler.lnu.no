# frozen_string_literal: true

# This caches all SVGs in assets folder, and solves inline svg for
# production use.

InlineSvg.configure do |config|
  # Only precompile if we aren't compiling on the fly
  break if Rails.application.config.assets.compile

  assets_path = Rails.public_path.join("assets").to_s
  break unless Dir.exist? assets_path

  config.asset_file = InlineSvg::CachedAssetFile.new(
    paths: [
      assets_path
    ],
    filters: /\.svg/
  )
end
