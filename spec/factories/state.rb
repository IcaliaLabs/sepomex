# frozen_string_literal: true

FactoryBot.define do
  factory :state do
    name { 'CDMX' }
    cities_count { 30 }
    sequence(:inegi_state_code) { |n| n }
  end
end
