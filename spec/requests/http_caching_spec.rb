# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'HTTP caching' do
  it 'marks successful GETs as publicly cacheable' do
    get '/api/v1/states'

    expect(response).to have_http_status(:ok)
    expect(response.headers['Cache-Control']).to include('public')
    expect(response.headers['Cache-Control']).to match(/max-age=\d+/)
  end

  it 'returns 304 Not Modified for a conditional GET with a matching ETag' do
    get '/api/v1/states'
    etag = response.headers['ETag']
    expect(etag).to be_present

    get '/api/v1/states', headers: { 'If-None-Match' => etag }

    expect(response).to have_http_status(:not_modified)
  end
end
