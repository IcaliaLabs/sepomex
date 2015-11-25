require './config/env'
require './sepomex'
require 'grape-active_model_serializers'

map '/api' do
  use Rack::Cors do
    allow do
      origins '*'
      resource '*',
        :headers => :any,
        :methods => :get
    end
  end

  use ActiveRecord::ConnectionAdapters::ConnectionManagement

  run Sepomex
end
