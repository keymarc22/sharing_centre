source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 2.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "devise", "~> 4.9"

# This library provides integration of the money gem with Rails.
gem 'money-rails', '~> 1.12'

gem "shadcn-ui", "~> 0.0.15"

gem "tailwindcss-rails", "~> 4.2"

gem "lucide-rails"

gem "phlex-rails", "~> 2.3"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "factory_bot_rails"
  # Patch-level verification for bundler.
  gem "bundler-audit"
  gem "brakeman"
end

group :test  do
  gem 'rspec-rails', '~> 8.0.0'
  gem 'database_cleaner-active_record'
end
