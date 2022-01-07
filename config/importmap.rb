# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"

pin "mapbox-gl" # @2.7.0
pin "tom-select" # @2.0.0
pin "@splidejs/splide", to: "@splidejs--splide.js" # @3.6.9
pin "process" # @2.0.0
