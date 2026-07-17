# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Municipalities', type: :request do
  let!(:municipality) { FactoryBot.create(:municipality) }

  path '/api/v1/municipalities' do
    get 'List municipalities' do
      tags 'Municipalities'
      produces 'application/json'
      parameter name: :per_page, in: :query, required: false, schema: { type: :integer }
      parameter name: :page, in: :query, required: false, schema: { type: :integer }
      let(:per_page) { nil }
      let(:page) { nil }

      response '200', 'paginated municipalities' do
        schema '$ref' => '#/components/schemas/MunicipalityList'
        run_test!
      end
    end
  end

  path '/api/v1/municipalities/{id}' do
    parameter name: :id, in: :path, required: true, schema: { type: :integer }

    get 'Get a municipality' do
      tags 'Municipalities'
      produces 'application/json'

      response '200', 'a municipality' do
        schema type: :object, properties: { municipality: { '$ref' => '#/components/schemas/Municipality' } }
        let(:id) { municipality.id }
        run_test!
      end

      response '404', 'municipality not found' do
        schema '$ref' => '#/components/schemas/Error'
        let(:id) { 0 }
        run_test!
      end
    end
  end
end
