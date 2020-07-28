# frozen_string_literal: true

class StateSerializer < ActiveModel::Serializer
  attributes :id, :name, :cities_count
end
