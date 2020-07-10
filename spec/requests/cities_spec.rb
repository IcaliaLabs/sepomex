# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'City requests' do
  describe 'GET/city' do
    it 'is a valid route' do
      get('/city')
      expect(response).to have_http_status(:success)
    end

    it 'return results' do
      get('/city')
      results = JSON.parse(response.body)
      expect(results).to include('cities')
    end

    it 'has pagination' do
      get('/city')
      results = JSON.parse(response.body)
      expect(results).to include('meta')
      expect(results['meta']).to include('pagination')
    end
  end
end
