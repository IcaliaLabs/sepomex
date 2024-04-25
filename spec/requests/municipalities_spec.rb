# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Municipality requests' do
  describe 'GET/municipality' do
    before do
      get('/api/v1/municipalities')
    end

    it 'is a valid route' do
      expect(response).to have_http_status(:success)
    end

    it 'return results' do
      results = JSON.parse(response.body)

      expect(results).to include('municipalities')
    end

    it 'has pagination' do
      results = JSON.parse(response.body)

      expect(results).to include('meta')
      expect(results['meta']).to include('pagination')
    end
  end
end
