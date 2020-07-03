# frozen_string_literal: true

Rails.application.routes.draw do
  # Zipcodes routes
  get '/zipcodes', to: 'zip_code#index'

  # States routes
  get '/states', to: 'state#index'
  get '/state/:id', to: 'state#find_by_id'
  get '/state/:id/municipalities', to: 'state#municipalities'

  # Municipalities routes
  get '/municipalities', to: 'municipality#index'
  get '/municipality/:id', to: 'municipality#find_by_id'

  # Cities routes
  get '/cities', to: 'city#index'
  get '/city/:id', to: 'city#find_by_id'
end
