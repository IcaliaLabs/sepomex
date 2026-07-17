# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s
  config.openapi_format = :yaml

  pagination_meta = {
    type: :object,
    properties: {
      pagination: {
        type: :object,
        properties: {
          per_page: { type: :integer, example: 15 },
          total_pages: { type: :integer, example: 9728 },
          total_objects: { type: :integer, example: 145_906 },
          links: {
            type: :object,
            properties: {
              first: { type: :string },
              last: { type: :string },
              prev: { type: :string },
              next: { type: :string }
            }
          }
        }
      }
    }
  }

  zip_code = {
    type: :object,
    properties: {
      id: { type: :integer },
      d_codigo: { type: :string, example: '01000' },
      d_asenta: { type: :string, example: 'San Ángel' },
      d_tipo_asenta: { type: :string, example: 'Colonia' },
      d_mnpio: { type: :string, example: 'Álvaro Obregón' },
      d_estado: { type: :string, example: 'Ciudad de México' },
      d_ciudad: { type: :string, nullable: true },
      d_cp: { type: :string, example: '01001' },
      c_estado: { type: :string, example: '09' },
      c_oficina: { type: :string },
      c_cp: { type: :string, nullable: true },
      c_tipo_asenta: { type: :string },
      c_mnpio: { type: :string },
      id_asenta_cpcons: { type: :string },
      d_zona: { type: :string, example: 'Urbano' },
      c_cve_ciudad: { type: :string, nullable: true }
    }
  }

  state = {
    type: :object,
    properties: {
      id: { type: :integer },
      name: { type: :string, example: 'Ciudad de México' },
      cities_count: { type: :integer, example: 16 }
    }
  }

  municipality = {
    type: :object,
    properties: {
      id: { type: :integer },
      name: { type: :string, example: 'Álvaro Obregón' },
      municipality_key: { type: :string, example: '010' },
      zip_code: { type: :string, example: '01001' },
      state_id: { type: :integer }
    }
  }

  city = {
    type: :object,
    properties: {
      id: { type: :integer },
      name: { type: :string, example: 'Ciudad de México' },
      state_id: { type: :integer }
    }
  }

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Sepomex API',
        version: 'v1',
        description: <<~DESC,
          Open REST API for Mexico's postal-code (código postal) catalog — zip
          codes (settlements), states, municipalities and cities. Read-only,
          public, no API key. Paginated with 15 items per page (max 200).
        DESC
        license: { name: 'MIT', url: 'https://github.com/IcaliaLabs/sepomex/blob/main/LICENSE' }
      },
      servers: [
        { url: 'https://sepomex.icalialabs.com', description: 'Production' },
        { url: 'http://localhost:3000', description: 'Local' }
      ],
      paths: {},
      components: {
        schemas: {
          ZipCode: zip_code,
          State: state,
          Municipality: municipality,
          City: city,
          PaginationMeta: pagination_meta,
          ZipCodeList: {
            type: :object,
            properties: { zip_codes: { type: :array, items: zip_code }, meta: pagination_meta }
          },
          StateList: {
            type: :object,
            properties: { states: { type: :array, items: state }, meta: pagination_meta }
          },
          MunicipalityList: {
            type: :object,
            properties: { municipalities: { type: :array, items: municipality }, meta: pagination_meta }
          },
          CityList: {
            type: :object,
            properties: { cities: { type: :array, items: city }, meta: pagination_meta }
          },
          Error: {
            type: :object,
            properties: {
              error: { type: :string, example: 'Not Found' },
              message: { type: :string },
              status: { type: :integer, example: 404 }
            }
          }
        }
      }
    }
  }
end
