# frozen_string_literal: true

module SepomexMcp
  module Tools
    # Shared helpers for the SEPOMEX MCP tools.
    #
    # Each concrete tool subclasses this, declares its `tool_name`, `description`
    # and `input_schema`, and implements `self.call`. Responses carry both a
    # human-readable text block (for clients that only read `content`) and
    # `structured_content` (the same records, serialized via the REST serializers)
    # for clients that consume structured output.
    class Base < MCP::Tool
      DEFAULT_LIMIT = 25
      MAX_LIMIT = 200

      class << self
        private

        # Serializes a record or relation into plain, string-keyed attribute
        # hashes using the existing Active Model Serializers (attributes adapter
        # → no root key). String keys keep `structured_content` identical to what
        # clients receive once the response is JSON-encoded on the wire.
        def serialize(resource)
          serialized = ActiveModelSerializers::SerializableResource.new(
            resource, adapter: :attributes
          ).as_json
          if serialized.is_a?(Array)
            serialized.map(&:deep_stringify_keys)
          else
            serialized.deep_stringify_keys
          end
        end

        # Builds a tool response with a summary line plus the serialized data.
        def respond(summary, data = nil)
          text = data.nil? ? summary : "#{summary}\n\n#{JSON.pretty_generate(data)}"
          MCP::Tool::Response.new(
            [{ type: 'text', text: text }],
            structured_content: data
          )
        end

        # Coerces a client-supplied limit into 1..MAX_LIMIT (default DEFAULT_LIMIT).
        def bounded_limit(value)
          limit = value.to_i
          limit = DEFAULT_LIMIT if limit < 1
          [limit, MAX_LIMIT].min
        end
      end
    end
  end
end
