# frozen_string_literal: true

module SepomexMcp
  # Namespace + registry for the MCP tools.
  module Tools
    module_function

    # The tool classes exposed by the server, in listing order.
    def all
      [
        LookupZipCode,
        SearchZipCodes,
        ListStates,
        StateMunicipalities,
        SearchCities
      ]
    end
  end
end
