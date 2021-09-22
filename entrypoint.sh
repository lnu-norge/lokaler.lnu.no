#!/bin/bash
# This script is run every time the container starts
set -e
role=${CONTAINER_ROLE:-web}






if [ "$role" = "web" ]; then
    # Run DB migrations
    bin/rails db:migrate RAILS_ENV=development
    # Run webpack before running the server so that we don't get 404s on the files
    bundle exec bin/webpack
    exec "$@"

elif [ "$role" == "webpack" ]; then
    bundle exec bin/webpack-dev-server

else
    echo "Could not match the container role \"$role\""
    exit 1
fi