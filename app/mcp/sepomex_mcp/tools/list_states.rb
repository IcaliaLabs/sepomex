# frozen_string_literal: true

module SepomexMcp
  module Tools
    # List all Mexican states.
    class ListStates < Base
      tool_name 'list_states'
      title 'List states'
      description <<~DESC
        List all 32 Mexican states with their id, name and number of cities.
        Use a returned state id with `state_municipalities`.
      DESC
      input_schema(properties: {})

      def self.call(server_context: nil, **_ignored)
        states = State.order(:name)
        respond("#{states.size} states.", serialize(states))
      end
    end
  end
end
