# frozen_string_literal: true

module SepomexMcp
  module Tools
    # Search cities by name.
    class SearchCities < Base
      tool_name 'search_cities'
      title 'Search cities'
      description <<~DESC
        Search cities by name (partial, case-insensitive), or list them when no
        query is given. Returns each city's id, name and state id.
      DESC
      input_schema(
        properties: {
          query: { type: 'string', description: 'City name fragment (e.g. "guad"). Omit to list from the top.' },
          limit: { type: 'integer', description: "Max results (1-#{MAX_LIMIT}, default #{DEFAULT_LIMIT})." }
        }
      )

      def self.call(query: nil, limit: nil, server_context: nil, **_ignored)
        limit = bounded_limit(limit)
        scope = City.order(:name)
        scope = scope.where('name LIKE ?', "%#{query.to_s.strip}%") if query.present?

        total = scope.count(:all)
        records = scope.limit(limit)

        described = query.present? ? " matching #{query.inspect}" : ''
        respond("Found #{total} city/cities#{described}; showing #{records.size}.", serialize(records))
      end
    end
  end
end
