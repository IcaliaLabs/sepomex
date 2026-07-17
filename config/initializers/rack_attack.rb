# frozen_string_literal: true

# Basic abuse protection for the public, key-less API. Throttles by client IP.
#
# Counts live in a dedicated in-memory store (per process), so throttling works
# regardless of the configured Rails.cache (which is null_store here). Limits are
# tunable via ENV: RATE_LIMIT (requests) and RATE_LIMIT_PERIOD (seconds).
class Rack::Attack
  self.cache.store = ActiveSupport::Cache::MemoryStore.new

  THROTTLE_LIMIT = Integer(ENV.fetch('RATE_LIMIT', 300))
  THROTTLE_PERIOD = Integer(ENV.fetch('RATE_LIMIT_PERIOD', 300))

  # Never throttle loopback traffic or the health check.
  safelist('allow from localhost') do |request|
    ['127.0.0.1', '::1'].include?(request.ip)
  end

  safelist('allow health check') do |request|
    request.path == '/up'
  end

  throttle('req/ip', limit: THROTTLE_LIMIT, period: THROTTLE_PERIOD, &:ip)

  # Answer throttled requests with JSON + a Retry-After header.
  self.throttled_responder = lambda do |request|
    match_data = request.env['rack.attack.match_data'] || {}
    retry_after = (match_data[:period] || THROTTLE_PERIOD).to_s

    [
      429,
      { 'Content-Type' => 'application/json', 'Retry-After' => retry_after },
      [{ error: 'Too many requests. Please retry later.' }.to_json]
    ]
  end
end
