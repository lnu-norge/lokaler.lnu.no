// Entry point for the build script in your package.json

import "@hotwired/turbo-rails"
import * as ActiveStorage from "@rails/activestorage"
import "./channels"
import "./controllers"

// Charts
import "chartkick/chart.js"

// Posthog for tracking
import "./custom/posthog"

// Rich text through trix and actiontext, with some custom config
import "./custom/custom_trix"
import "@rails/actiontext"

ActiveStorage.start()
