#!/bin/bash
# This script is run every time the container starts

# Exit on any error
set -e

# If running the rails server
if [ "${1}" == "./bin/rails" ] && [ "${2}" == "server" ]; then
  # Make sure db is ready to go
  bundle exec rails db:prepare
fi

# Then exec the container's main process (CMD in the Dockerfile).
exec "${@}"
