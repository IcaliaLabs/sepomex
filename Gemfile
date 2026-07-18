# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.7'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 8.0'

# Use sqlite3 as the database for Active Record
gem 'sqlite3', '>= 2.1'

# Use Puma as the app server
gem 'puma', '>= 6.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.18', require: false

# The CSV library provides a complete interface to CSV files and data.
gem 'csv', '~> 3.3'

# JSON:API-style serialization (preserves the public response contract)
gem 'active_model_serializers', '~> 0.10.14'

# Rack CORS for handling Cross-Origin Resource Sharing (cross-origin AJAX)
gem 'rack-cors', '~> 2.0'

# Throttling / abuse protection for the public API
gem 'rack-attack', '~> 6.7'

# Model Context Protocol server — exposes the API as agentic tools
gem 'mcp', '~> 0.4'

# OpenAPI/Swagger docs: rswag-specs generates the spec from request specs;
# rswag-api serves it and rswag-ui renders the interactive Swagger UI.
gem 'rswag-api', '~> 2.13'
gem 'rswag-ui', '~> 2.13'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem 'listen', '~> 3.9'

  # Ruby's built-in debugger (replaces byebug / debase / ruby-debug-ide)
  gem 'debug', platforms: %i[mri mingw x64_mingw], require: false
end

group :development do
  # Security scanners (also run in CI):
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false

  # Ruby code linters:
  gem 'reek', '~> 6.3', require: false

  gem 'rubocop',             '~> 1.60', require: false
  gem 'rubocop-performance', '~> 1.20', require: false
  gem 'rubocop-rails',       '~> 2.23', require: false
  gem 'rubocop-rspec',       '~> 3.0',  require: false

  # IDE tools for code completion, inline documentation, and static analysis
  gem 'solargraph', '~> 0.50', require: false
end

group :test do
  gem 'factory_bot_rails', '~> 6.4'
  gem 'rspec-rails', '>= 7.1'
  gem 'rswag-specs', '~> 2.13'
  gem 'shoulda-matchers', '~> 6.0'

  # Test coverage (+ lcov report for the Codecov upload / badge)
  gem 'simplecov', '~> 1.0', require: false
  gem 'simplecov-lcov', '~> 0.8', require: false
end
