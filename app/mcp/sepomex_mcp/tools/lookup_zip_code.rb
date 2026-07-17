# frozen_string_literal: true

module SepomexMcp
  module Tools
    # Resolve a single postal code to all of its settlements.
    class LookupZipCode < Base
      tool_name 'lookup_zip_code'
      title 'Look up a postal code'
      description <<~DESC
        Resolve a single Mexican postal code (código postal) to all of its
        settlements (colonias), including the state and municipality it belongs to.
        Use this when you have a specific 5-digit CP (e.g. "64000").
      DESC
      input_schema(
        properties: {
          zip_code: { type: 'string', description: 'Exact 5-digit postal code, e.g. "64000".' }
        },
        required: ['zip_code']
      )

      def self.call(zip_code: nil, server_context: nil, **_ignored)
        cp = zip_code.to_s.strip
        records = ZipCode.where(d_codigo: cp).order(:d_asenta)

        return respond("No settlements found for postal code #{cp.inspect}.") if records.empty?

        first = records.first
        summary = "Postal code #{cp}: #{records.size} settlement(s) in " \
                  "#{first.d_mnpio}, #{first.d_estado}."
        respond(summary, serialize(records))
      end
    end
  end
end
