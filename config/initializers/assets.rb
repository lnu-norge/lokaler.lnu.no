# frozen_string_literal: true

# Be sure to restart your server when you modify this file.
#
# Propshaft serves and fingerprints whatever it finds on the asset paths; it
# compiles nothing. esbuild writes app/assets/builds/application.js and postcss
# writes app/assets/builds/application.css, driven by jsbundling-rails and
# cssbundling-rails, and Propshaft only digests the results.
#
# app/assets/builds and app/assets/images are on the load path by default, so
# there is nothing to add here. Favicons deliberately live in public/favicon and
# bypass the pipeline entirely.
#
# Build inputs are kept off the asset paths via config.assets.excluded_paths in
# config/application.rb — it has to be set there, because Propshaft applies the
# exclusion inside its own initializer, which runs after this file.
#
# Removed with Sprockets, all of them Sprockets-only settings:
#   config.assets.version                 - Propshaft digests by content
#   config.assets.check_precompiled_asset - no equivalent, and nothing needed it
#   config.assets.paths << node_modules   - vestigial; nothing resolves assets
#                                           from node_modules, esbuild bundles
#                                           those into application.js instead
