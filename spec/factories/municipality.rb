# frozen_string_literal: true

FactoryBot.define do
  factory :municipality do
    name { 'Álvaro Obregón' }
    sequence(:municipality_key) { |n| format('%03d', n) }
    zip_code { '01000' }
    association :state
  end
end
