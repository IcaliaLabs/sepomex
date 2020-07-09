# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ZipCode requests' do
  describe 'GET/zip_code' do
    it 'is a valid route' do
      get('/zip_code')
      expect(response).to have_http_status(:success)
    end

    it 'return results' do
      get('/zip_code')
      results = JSON.parse(response.body)
      expect(results).to include('zip_codes')
    end

    it 'has pagination' do
      get('/zip_code')
      results = JSON.parse(response.body)
      expect(results).to include('meta')
      expect(results['meta']).to include('pagination')
    end
  end
end
