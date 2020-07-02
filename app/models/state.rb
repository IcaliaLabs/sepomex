class State < ApplicationRecord
  has_many :municipalities
  has_many :cities
end
