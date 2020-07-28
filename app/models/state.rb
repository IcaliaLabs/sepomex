class State < ApplicationRecord
  validates_presence_of :name
  has_many :municipalities
  has_many :cities
end
