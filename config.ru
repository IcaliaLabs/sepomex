require './config/env'
require './sepomex'

map '/api' do
  run Sepomex
end
