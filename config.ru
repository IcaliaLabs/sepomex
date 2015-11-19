require './config/env'
require './sepomex'

map '/api' do

  use Rack::Cors do
    allow do
      origins '*'
      resource '/*', :headers => :any, :methods => [:get, :post, :options, :put]
    end
  end

  run Sepomex
end