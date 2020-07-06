# frozen_string_literal: true

Rails.application.routes.draw do
  resources :zip_code, only: %i[index]

  resources :state, only: %i[index show]
  get '/state/:id/municipalities', to: 'state#municipalities'

  resources :municipality, only: %i[index show]

  resources :city, only: %i[index show]
end
