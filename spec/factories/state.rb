# frozen_string_literal: true

FactoryBot.define do
  factory :state do
    name { 'CDMX' }
    cities_count { 30 }
  end
end
