# frozen_string_literal: true

# Common seeds:
require './db/seeds/common'

# Development only seeds

## Create a User:
User.create(
  email: 'user@example.com',
  password: 'user_password',
  password_confirmation: 'user_password'
)

# Fake, empty Space data for Gudeberg school:
require './db/seeds/spaces/gudeberg_no_info'

# Fake school that does not want to be listed
require './db/seeds/spaces/nabbetorp_no_booking'

# Fake, full Space data for Frederik II
require './db/seeds/spaces/frederikii_full_space'
