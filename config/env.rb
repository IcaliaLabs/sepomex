require 'pathname'
require 'bundler'
require 'rake'
require 'bundler/setup'
require 'grape/activerecord/rake'

Bundler.require(:default, ENV['RACK_ENV'] || :development)


ROOT = Pathname.new(File.expand_path('../..', __FILE__))

Dir.glob(ROOT.join('app', 'models', '*.rb')).each { |file| require file }
Dir.glob(ROOT.join('app', 'serializers', '*.rb')).each { |file| require file }
Dir.glob(ROOT.join('app', 'helpers', '*.rb')).each { |file| require file }
Dir.glob(ROOT.join('app', 'api', '**', '*.rb')).each { |file| require file }

Grape::ActiveRecord.configure_from_url! ENV['DATABASE_URL'] # e.g. postgres://user:pass@host/db

