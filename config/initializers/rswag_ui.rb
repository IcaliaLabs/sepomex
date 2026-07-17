# frozen_string_literal: true

Rswag::Ui.configure do |c|
  # Swagger UI (served at /api-docs) points at the generated spec.
  c.openapi_endpoint '/api-docs/v1/swagger.yaml', 'Sepomex API V1'
end
