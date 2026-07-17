# frozen_string_literal: true

module SepomexMcp
  module Tools
    # Search postal-code settlements by any combination of filters.
    class SearchZipCodes < Base
      tool_name 'search_zip_codes'
      title 'Search postal codes'
      description <<~DESC
        Search Mexican postal-code settlements (colonias) by any combination of
        zip code, state, city/municipality and colony name (all partial and
        accent-insensitive). Returns matching settlements with their state,
        municipality and CP. Results are capped by `limit` (default #{DEFAULT_LIMIT},
        max #{MAX_LIMIT}); `total` in the summary reports the full match count.
      DESC
      input_schema(
        properties: {
          zip_code: { type: 'string', description: 'Postal code, full or partial (e.g. "64").' },
          state: { type: 'string', description: 'State name, accent-insensitive (e.g. "nuevo leon").' },
          city: { type: 'string', description: 'City or municipality name (e.g. "monterrey").' },
          colony: { type: 'string', description: 'Colony / settlement name (e.g. "del valle").' },
          limit: { type: 'integer', description: "Max results to return (1-#{MAX_LIMIT}, default #{DEFAULT_LIMIT})." }
        }
      )

      def self.call(zip_code: nil, state: nil, city: nil, colony: nil, limit: nil, server_context: nil, **_ignored)
        filters = { zip_code: zip_code, state: state, city: city, colony: colony }
                  .compact_blank
                  .with_indifferent_access
        limit = bounded_limit(limit)

        scope = ZipCode.search(filters)
        total = scope.count(:all)
        records = scope.limit(limit)

        described = filters.present? ? " matching #{filters.to_h}" : ''
        summary = "Found #{total} settlement(s)#{described}; showing #{records.size}."
        respond(summary, serialize(records))
      end
    end
  end
end
