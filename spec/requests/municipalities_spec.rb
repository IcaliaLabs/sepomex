# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Municipality requests' do
  describe 'GET/municipality' do
    it 'is a valid route' do
      get('/municipality')
      expect(response).to have_http_status(:success)
    end

    it 'return results' do
      get('/municipality')
      results = JSON.parse(response.body)
      expect(results).to include('municipalities')
    end

    it 'has pagination' do
      get('/municipality')
      results = JSON.parse(response.body)
      expect(results).to include('meta')
      expect(results['meta']).to include('pagination')
    end
  end
end
