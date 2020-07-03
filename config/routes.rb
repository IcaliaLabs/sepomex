# frozen_string_literal: true

Rails.application.routes.draw do
  # States routes
  get '/states', to: 'state#index'
  get '/state/:id', to: 'state#find_by_id'

  # Municipalities routes
  get '/municipalities', to: 'municipality#index'
  get '/municipality/:id', to: 'municipality#find_by_id'
end
