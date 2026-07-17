# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Rate limiting' do
  # A non-loopback IP, so the localhost safelist doesn't apply.
  let(:client_ip) { '203.0.113.7' }

  before do
    Rack::Attack.enabled = true
    Rack::Attack.cache.store.clear
  end

  # Add a strict, temporary throttle so the limit is reachable in a test.
  around do |example|
    Rack::Attack.throttle('test/req/ip', limit: 2, period: 60, &:ip)
    example.run
  ensure
    Rack::Attack.throttles.delete('test/req/ip')
  end

  it 'returns 429 with a JSON body once the limit is exceeded' do
    3.times { get '/api/v1/states', headers: { 'REMOTE_ADDR' => client_ip } }

    expect(response).to have_http_status(:too_many_requests)
    expect(response.headers['Retry-After']).to be_present
    expect(JSON.parse(response.body)).to include('error')
  end

  it 'serves requests under the limit' do
    2.times { get '/api/v1/states', headers: { 'REMOTE_ADDR' => client_ip } }

    expect(response).to have_http_status(:ok)
  end

  it 'never throttles the health check' do
    5.times { get '/up', headers: { 'REMOTE_ADDR' => client_ip } }

    expect(response).to have_http_status(:ok)
  end
end
