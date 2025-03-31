# frozen_string_literal: true

# For HEROKU only, delete if we are no longer on Heroku
# rubocop:disable Style/GlobalVars -- This is a global variable that Heroku needs
$redis = Redis.new(url: ENV.fetch("REDIS_URL", nil), ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
# rubocop:enable Style/GlobalVars
