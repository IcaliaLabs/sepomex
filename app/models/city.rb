class City < ApplicationRecord
  validates_presence_of :name
  belongs_to :state
end
