# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Zip Codes', type: :request do
  before { FactoryBot.create(:zip_code) }

  path '/api/v1/zip_codes' do
    get 'Search zip codes' do
      tags 'Zip Codes'
      description 'Search settlements (colonias) by any combination of zip_code, ' \
                  'state, city/municipality and colony. All filters are partial and ' \
                  'accent-insensitive.'
      produces 'application/json'
      parameter name: :zip_code, in: :query, required: false, schema: { type: :string },
                description: 'Postal code, full or partial (e.g. "64000")'
      parameter name: :state, in: :query, required: false, schema: { type: :string }
      parameter name: :city, in: :query, required: false, schema: { type: :string }
      parameter name: :colony, in: :query, required: false, schema: { type: :string }
      parameter name: :per_page, in: :query, required: false, schema: { type: :integer },
                description: 'Items per page (default 15, max 200)'
      parameter name: :page, in: :query, required: false, schema: { type: :integer }

      let(:zip_code) { nil }
      let(:state) { nil }
      let(:city) { nil }
      let(:colony) { nil }
      let(:per_page) { nil }
      let(:page) { nil }

      response '200', 'matching settlements' do
        schema '$ref' => '#/components/schemas/ZipCodeList'
        run_test!
      end
    end
  end
end
