# frozen_string_literal: true

# A settlement (colonia) row from the SEPOMEX catalog — the core searchable
# record. `ZipCode.search` powers both the REST endpoint and the MCP tool, and
# `build_indexes` maintains the fts_zip_codes helper table used by the search
# scopes.
class ZipCode < ApplicationRecord
  has_one :fts_zip_code, dependent: :destroy
  validates :d_codigo, presence: true

  default_scope { order(:id) }

  scope :find_by_zip_code, lambda { |cp|
    where('lower(d_codigo) LIKE lower(?)', "%#{cp}%")
  }

  scope :find_by_state, lambda { |state|
    fts_search('d_estado', state)
  }

  scope :find_by_city, lambda { |city|
    fts_search(%w[d_ciudad d_mnpio], city)
  }

  scope :find_by_colony, lambda { |colony|
    fts_search('d_asenta', colony)
  }

  def self.search(params = {})
    zip_codes = all

    if params[:cp].present? || params[:zip_code].present?
      zip_codes = zip_codes.find_by_zip_code(params['cp'] || params['zip_code'])
    end

    # FTS5 allows a single MATCH per query, so the state/city/colony filters are
    # combined into one boolean MATCH expression rather than chained scopes.
    fts = fts_conditions(params)
    zip_codes = zip_codes.joins(:fts_zip_code).where('fts_zip_codes MATCH ?', fts) if fts

    zip_codes
  end

  def self.c_estado
    arel_table[:c_estado]
  end

  def self.c_cve_ciudad
    arel_table[:c_cve_ciudad]
  end

  def self.d_estado
    arel_table[:d_estado]
  end

  def self.d_ciudad
    arel_table[:d_ciudad]
  end

  def self.cities_data_except_cmdx
    select(
      d_estado.minimum.as('"d_estado"'),
      c_estado,
      d_ciudad.minimum.as('"d_ciudad"'),
      c_cve_ciudad
    ).where(
      c_estado.not_eq('09').and(c_cve_ciudad.not_eq(nil))
    ).group(:c_estado, :c_cve_ciudad).reorder :c_estado, :c_cve_ciudad
  end

  def self.cmdx_cities_data
    select(
      d_estado.minimum.as('"d_estado"'),
      c_estado,
      d_ciudad.minimum.as('"d_ciudad"'),
      c_cve_ciudad.minimum.as('"c_cve_ciudad"')
    ).where(c_estado: '09').group(:c_estado).reorder(
      :c_estado, c_cve_ciudad.minimum.asc
    )
  end

  FTS_COLUMNS = %w[d_ciudad d_estado d_asenta d_mnpio].freeze

  # Rebuilds the fts_zip_codes FTS5 index from every zip code. Raw values are
  # stored — the `remove_diacritics` tokenizer folds case and accents itself.
  # FTS5 virtual tables can't use insert_all (no unique index), so rows are bulk
  # INSERTed in batches; every value goes through connection.quote (safe).
  def self.build_indexes
    all.in_batches(of: 5_000) do |batch|
      values = batch.map { |item| fts_row_values(item) }
      connection.execute(<<~SQL.squish)
        INSERT INTO fts_zip_codes (#{FTS_COLUMNS.join(', ')}, zip_code_id)
        VALUES #{values.join(', ')}
      SQL
    end
  end

  def self.fts_row_values(item)
    quoted = FTS_COLUMNS.map { |column| connection.quote(item[column].to_s) }
    "(#{quoted.join(', ')}, #{item.id.to_i})"
  end

  # Relation matching the FTS5 index for one column (or set of columns).
  def self.fts_search(columns, value)
    query = fts_column_query(columns, value)
    query ? joins(:fts_zip_code).where('fts_zip_codes MATCH ?', query) : none
  end

  # Combines the state/city/colony filters into a single boolean FTS5 MATCH
  # expression (nil when none are present).
  def self.fts_conditions(params)
    [
      (fts_column_query('d_estado', params['state']) if params[:state].present?),
      (fts_column_query(%w[d_ciudad d_mnpio], params['city']) if params['city'].present?),
      (fts_column_query('d_asenta', params['colony']) if params[:colony].present?)
    ].compact.join(' AND ').presence
  end

  # Turns user input into a safe, column-scoped FTS5 prefix query — e.g.
  # ("Monterrey", %w[d_ciudad d_mnpio]) => "{d_ciudad d_mnpio} : (monterrey*)".
  # Only alphanumeric tokens survive, so the MATCH expression can't be injected.
  def self.fts_column_query(columns, value)
    tokens = value.to_s.scan(/[[:alnum:]]+/)
    return if tokens.empty?

    "{#{Array(columns).join(' ')}} : (#{tokens.map { |token| "#{token}*" }.join(' ')})"
  end

  def self.alpharize(text)
    text.downcase.parameterize(separator: ' ')
  end
end
