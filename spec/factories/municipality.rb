# frozen_string_literal: true

FactoryBot.define do
  factory :municipality do
    name { 'Álvaro Obregón' }
    municipality_key { '09' }
    zip_code { '01000' }
    state_id { 123 }
  end
end
