# frozen_string_literal: true

# SepomexMcp
#
# Builds the Model Context Protocol server that exposes Mexico's postal-code
# catalog as agentic tools. The same server object is served over Streamable
# HTTP (see McpController) and over stdio (see bin/mcp), and every tool reuses
# the very same models/scopes the REST API uses, so both surfaces stay in sync.
module SepomexMcp
  NAME = 'sepomex'
  VERSION = '1.0.0'

  INSTRUCTIONS = <<~TEXT.freeze
    SEPOMEX exposes Mexico's official postal-code (código postal / CP) catalog:
    ~145,000 settlements (colonias) across 32 states, ~2,475 municipalities and
    ~660 cities. All data is read-only.

    Tools:
    - lookup_zip_code: resolve a single CP to its settlements, state and municipality.
    - search_zip_codes: filter settlements by zip code, state, city/municipality or colony.
    - list_states: list the 32 states (use a state id with state_municipalities).
    - state_municipalities: list the municipalities of a state.
    - search_cities: find cities by name.
  TEXT

  module_function

  # Returns a fresh MCP::Server. Cheap to build, so callers may create one per
  # request (the HTTP transport runs stateless).
  def server(server_context: nil)
    MCP::Server.new(
      name: NAME,
      title: 'SEPOMEX — Mexican Postal Codes',
      version: VERSION,
      instructions: INSTRUCTIONS,
      tools: Tools.all,
      server_context: server_context
    )
  end
end
