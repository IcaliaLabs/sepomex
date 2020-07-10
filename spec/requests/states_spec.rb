# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'State requests' do
  describe 'GET/state' do
    it 'is a valid route' do
      get('/state')
      expect(response).to have_http_status(:success)
    end

    it 'return results' do
      get('/state')
      results = JSON.parse(response.body)
      expect(results).to include('states')
    end

    it 'has pagination' do
      get('/state')
      results = JSON.parse(response.body)
      expect(results).to include('meta')
      expect(results['meta']).to include('pagination')
    end
  end
end
