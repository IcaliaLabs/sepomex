class State < ActiveRecord::Base
  has_many :municipalities
  has_many :cities
end
