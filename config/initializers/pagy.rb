# frozen_string_literal: true

require "pagy"

# Pagy ships its own faster i18n implementation, but we use the I18n gem so
# pagination text keeps following Rails' I18n.locale (nb/en) like the rest of the app.
Pagy.translate_with_the_slower_i18n_gem!
