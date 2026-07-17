# frozen_string_literal: true

FactoryBot.define do
  factory :city do
    name { 'Monterrey' }
    association :state
    sequence(:sepomex_city_code) { |n| n }
  end
end
