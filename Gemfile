# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.7'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0', '>= 6.0.3.2'

# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.4'

# Use Puma as the app server
gem 'puma', '~> 4.3'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# The CSV library provides a complete interface to CSV files and data.
gem 'csv', '~> 3.1', '>= 3.1.5'

# Routines specially designed to run the app on development & live containers:
gem 'on_container', '~> 0.0.16'

# Pagination
gem 'active_model_serializers', '~> 0.10.10'
gem 'pager_api', '~> 0.3.2'
gem 'pagy', '~> 3.8', '>= 3.8.2'
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors', '~> 1.1', '>= 1.1.1'
# Testing

# Read secrets from Google Cloud Secret Manager
gem 'google-cloud-secret_manager', '~> 1.1', '>= 1.1.3'

group :development, :test do
  gem 'listen', '>= 3.0.5', '< 3.2'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Support for Ruby IDE tools - including "Ruby for Visual Studio Code"
  gem 'debase', '~> 0.2.4.1', require: false
  gem 'ruby-debug-ide', '~> 0.7.3', require: false

  # Ruby code linters:
  gem 'reek', '~> 6.1', require: false

  gem 'rubocop',             '~> 1.25', '>= 1.25.1', require: false
  gem 'rubocop-performance', '~> 1.13', '>= 1.13.2', require: false
  gem 'rubocop-rails',       '~> 2.13', '>= 2.13.2', require: false
  gem 'rubocop-rspec',       '~> 2.8',               require: false

  # IDE tools for code completion, inline documentation, and static analysis
  gem 'solargraph', '~> 0.45.0', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :test do
  gem 'factory_bot_rails', '~> 6.1'
  gem 'rspec-rails', '~> 4.0', '>= 4.0.1'
  gem 'shoulda-matchers', '~> 4.3'
end
