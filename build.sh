# Build the docs
bash build_api.sh

# install deps
bundle install
bundle exec middleman build --clean

# the docs are now avalible via the /build dir