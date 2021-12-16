# frozen_string_literal: true

# Common seeds:
require "./db/seeds/common"

# Development only seeds

## Create a User:
User.create(
  email: "user@example.com",
  password: "secret",
  password_confirmation: "secret",
  first_name: "Kari",
  last_name: "Nordmann",
  admin: true
)

# Fake schools
require "./db/seeds/spaces/grunnskoler"

# Fake, full Space data for Frederik II
require "./db/seeds/spaces/frederikii_full_space"
