source "https://rubygems.org"

gem "rails", "~> 8.0.1"
gem "puma", ">= 5.0"
gem "jbuilder"
gem "bcrypt", "~> 3.1.7"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem "image_processing", "~> 1.14"
gem "chartkick"
gem "groupdate"
gem "ransack"
gem "pagy"

# Database
gem "sqlite3", ">= 2.1"

# Asset Bundling
gem "propshaft"

# JS
gem "importmap-rails"
gem "stimulus-rails"
gem "turbo-rails"

# CSS
gem "tailwindcss-ruby", "~> 4.0"
gem "tailwindcss-rails", "~> 4.1"

# Solid Stack
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Production deployment
gem "kamal", require: false
gem "thruster", require: false


group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end
