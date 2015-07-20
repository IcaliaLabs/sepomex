class Sepomex < Grape::API
  include Grape::ActiveRecord::Extension
  mount API::V1
end
