# frozen_string_literal: true

class MunicipalitySerializer < ActiveModel::Serializer
  attributes :id, :name, :municipality_key, :zip_code, :state_id
end
