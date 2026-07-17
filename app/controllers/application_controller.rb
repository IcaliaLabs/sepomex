# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Paginatable

  # The catalog is read-only and changes rarely, so successful GETs are marked
  # publicly cacheable. Combined with the Rack::ETag / Rack::ConditionalGet
  # middleware this yields conditional GETs (304 Not Modified) for repeat calls.
  # Tune the window with HTTP_CACHE_TTL (seconds).
  HTTP_CACHE_TTL = Integer(ENV.fetch('HTTP_CACHE_TTL', 3600)).seconds

  after_action :set_cache_headers

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::ParameterMissing, with: :render_bad_request

  private

  def set_cache_headers
    return unless request.get? && response.successful?

    expires_in HTTP_CACHE_TTL, public: true
  end

  def render_not_found(exception)
    render_error(status: :not_found, error: 'Not Found', message: exception.message)
  end

  def render_bad_request(exception)
    render_error(status: :bad_request, error: 'Bad Request', message: exception.message)
  end

  # Consistent JSON error envelope: { "error", "message", "status" }.
  def render_error(status:, error:, message:)
    render json: { error: error, message: message, status: Rack::Utils.status_code(status) },
           status: status
  end
end
