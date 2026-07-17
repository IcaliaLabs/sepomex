# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Cities', type: :request do
  let!(:city) { FactoryBot.create(:city) }

  path '/api/v1/cities' do
    get 'List cities' do
      tags 'Cities'
      produces 'application/json'
      parameter name: :per_page, in: :query, required: false, schema: { type: :integer }
      parameter name: :page, in: :query, required: false, schema: { type: :integer }
      let(:per_page) { nil }
      let(:page) { nil }

      response '200', 'paginated cities' do
        schema '$ref' => '#/components/schemas/CityList'
        run_test!
      end
    end
  end

  path '/api/v1/cities/{id}' do
    parameter name: :id, in: :path, required: true, schema: { type: :integer }

    get 'Get a city' do
      tags 'Cities'
      produces 'application/json'

      response '200', 'a city' do
        schema type: :object, properties: { city: { '$ref' => '#/components/schemas/City' } }
        let(:id) { city.id }
        run_test!
      end

      response '404', 'city not found' do
        schema '$ref' => '#/components/schemas/Error'
        let(:id) { 0 }
        run_test!
      end
    end
  end
end
