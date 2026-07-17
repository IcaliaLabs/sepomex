# frozen_string_literal: true

# Model Context Protocol endpoint (Streamable HTTP transport).
#
# Serves the SEPOMEX MCP server at `/mcp` so remote MCP clients can query the
# postal-code catalog alongside the REST API. It runs stateless (a self-contained
# server per request) so it is safe under multiple Puma workers / instances, and
# returns a single JSON response rather than an SSE stream.
class McpController < ApplicationController
  def handle
    transport = MCP::Server::Transports::StreamableHTTPTransport.new(
      SepomexMcp.server(server_context: { request_id: request.request_id }),
      stateless: true,
      enable_json_response: true,
      # The postal data is public (like the REST API) and the app is served
      # behind a proxy on its own host, so the loopback-only Host/Origin guard
      # is disabled; re-enable with `allowed_hosts:` if locking this down.
      dns_rebinding_protection: false
    )

    status, rack_headers, body = transport.handle_request(request)

    rack_headers.each do |key, value|
      response.headers[key] = value unless key.casecmp?('content-type')
    end

    render body: Array(body).join,
           status: status,
           content_type: rack_headers['Content-Type'] || 'application/json'
  end
end
