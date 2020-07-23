# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ZipCode requests' do
  describe 'GET/zip_code' do
    before do
      get('/api/v1/zip_codes')
    end

    it 'is a valid route' do
      expect(response).to have_http_status(:success)
    end

    it 'return results' do
      results = JSON.parse(response.body)

      expect(results).to include('zip_codes')
    end

    it 'has pagination' do
      results = JSON.parse(response.body)

      expect(results).to include('meta')
      expect(results['meta']).to include('pagination')
    end
  end
end
