# frozen_string_literal: true

module SepomexMcp
  module Tools
    # List the municipalities of a given state.
    class StateMunicipalities < Base
      tool_name 'state_municipalities'
      title 'Municipalities of a state'
      description <<~DESC
        List the municipalities (municipios) of a state, given the state id
        returned by `list_states`.
      DESC
      input_schema(
        properties: {
          state_id: { type: 'integer', description: 'State id (see list_states).' }
        },
        required: ['state_id']
      )

      def self.call(state_id: nil, server_context: nil, **_ignored)
        state = State.find_by(id: state_id.to_i)
        return respond("No state found with id #{state_id.inspect}.") unless state

        municipalities = state.municipalities.order(:name)
        respond("#{state.name}: #{municipalities.size} municipalities.", serialize(municipalities))
      end
    end
  end
end
