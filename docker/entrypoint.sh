#!/bin/bash
set -e

# Install gem and npm dependencies, if necessary
bundle check || bundle install

bundle exec "$@"
