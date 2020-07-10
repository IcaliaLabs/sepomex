# frozen_string_literal: true

Rails.application.routes.draw do
  resources :zip_codes, only: %i[index]

  resources :states, only: %i[index show]

  get '/state/:id/municipalities', to: 'state#municipalities'

  resources :municipalities, only: %i[index show]

  resources :cities, only: %i[index show]
end
