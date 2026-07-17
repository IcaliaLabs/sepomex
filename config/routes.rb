# frozen_string_literal: true

Rails.application.routes.draw do
  # Interactive API docs (Swagger UI) + the raw OpenAPI spec, both under /api-docs.
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Liveness/readiness probe (returns 200 when the app boots without errors):
  get '/up' => 'rails/health#show', as: :rails_health_check

  # Model Context Protocol endpoint (Streamable HTTP: POST messages, GET/DELETE
  # session lifecycle). Lets MCP clients query the postal-code catalog as tools.
  match '/mcp', to: 'mcp#handle', via: %i[post get delete]

  namespace :api do
    namespace :v1 do
      resources :states, only: %i[index show]

      resources :zip_codes, only: %i[index]

      get '/states/:id/municipalities', to: 'states#municipalities'
      resources :municipalities, only: %i[index show]

      resources :cities, only: %i[index show]
    end
  end
end
