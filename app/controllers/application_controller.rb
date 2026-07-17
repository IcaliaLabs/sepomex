# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Paginatable

  # The catalog is read-only and changes rarely, so successful GETs are marked
  # publicly cacheable. Combined with the Rack::ETag / Rack::ConditionalGet
  # middleware this yields conditional GETs (304 Not Modified) for repeat calls.
  # Tune the window with HTTP_CACHE_TTL (seconds).
  HTTP_CACHE_TTL = Integer(ENV.fetch('HTTP_CACHE_TTL', 3600)).seconds

  after_action :set_cache_headers

  private

  def set_cache_headers
    return unless request.get? && response.successful?

    expires_in HTTP_CACHE_TTL, public: true
  end
end
