# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'City requests' do
  describe 'GET/city' do
    before do
      get('/cities')
    end

    it 'is a valid route' do
      expect(response).to have_http_status(:success)
    end

    it 'return results' do
      results = JSON.parse(response.body)

      expect(results).to include('cities')
    end

    it 'has pagination' do
      results = JSON.parse(response.body)

      expect(results).to include('meta')
      expect(results['meta']).to include('pagination')
    end
  end
end
