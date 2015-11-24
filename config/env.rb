require 'pathname'
require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'] || :development)


ROOT = Pathname.new(File.expand_path('../..', __FILE__))

Dir.glob(ROOT.join('app', 'models', '*.rb')).each { |file| require file }
Dir.glob(ROOT.join('app', 'serializers', '*.rb')).each { |file| require file }
Dir.glob(ROOT.join('app', 'helpers', '*.rb')).each { |file| require file }
Dir.glob(ROOT.join('app', 'api', '**', '*.rb')).each { |file| require file }

Grape::ActiveRecord.database_file = ROOT.join('config', 'database.yml')
