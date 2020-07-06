# frozen_string_literal: true

class CitySerializer < ActiveModel::Serializer
  attributes :id, :name, :state_id
end
