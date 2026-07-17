# frozen_string_literal: true

Rswag::Api.configure do |c|
  # Root folder where the generated OpenAPI files live.
  c.openapi_root = Rails.root.join('swagger').to_s
end
