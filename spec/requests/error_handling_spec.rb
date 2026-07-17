# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API error handling' do
  it 'returns a JSON 404 envelope for an unknown record' do
    get '/api/v1/states/999999'

    expect(response).to have_http_status(:not_found)
    body = JSON.parse(response.body)
    expect(body).to include('error' => 'Not Found', 'status' => 404)
    expect(body['message']).to be_present
  end

  it 'does not cache error responses' do
    get '/api/v1/states/999999'

    expect(response.headers['Cache-Control']).not_to include('public')
  end
end
