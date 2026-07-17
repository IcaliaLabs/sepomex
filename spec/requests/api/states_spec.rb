# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'States', type: :request do
  let!(:state) { FactoryBot.create(:state) }

  path '/api/v1/states' do
    get 'List states' do
      tags 'States'
      produces 'application/json'
      parameter name: :per_page, in: :query, required: false, schema: { type: :integer }
      parameter name: :page, in: :query, required: false, schema: { type: :integer }
      let(:per_page) { nil }
      let(:page) { nil }

      response '200', 'paginated states' do
        schema '$ref' => '#/components/schemas/StateList'
        run_test!
      end
    end
  end

  path '/api/v1/states/{id}' do
    parameter name: :id, in: :path, required: true, schema: { type: :integer }

    get 'Get a state' do
      tags 'States'
      produces 'application/json'

      response '200', 'a state' do
        schema type: :object, properties: { state: { '$ref' => '#/components/schemas/State' } }
        let(:id) { state.id }
        run_test!
      end

      response '404', 'state not found' do
        schema '$ref' => '#/components/schemas/Error'
        let(:id) { 0 }
        run_test!
      end
    end
  end

  path '/api/v1/states/{id}/municipalities' do
    parameter name: :id, in: :path, required: true, schema: { type: :integer }

    get "A state's municipalities" do
      tags 'States'
      produces 'application/json'

      response '200', 'municipalities of the state' do
        schema type: :object,
               properties: {
                 municipalities: { type: :array, items: { '$ref' => '#/components/schemas/Municipality' } }
               }
        let(:id) { state.id }
        run_test!
      end
    end
  end
end
