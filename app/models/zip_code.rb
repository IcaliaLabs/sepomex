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
    distinct.joins(:fts_zip_code).where('fts_zip_codes.d_estado LIKE ?', "%#{alpharize(state)}%")
  }

  scope :find_by_city, lambda { |city|
    city = "%#{alpharize(city)}%"
    distinct.joins(:fts_zip_code).where('fts_zip_codes.d_ciudad LIKE ? OR fts_zip_codes.d_mnpio LIKE ?', city, city)
  }

  scope :find_by_colony, lambda { |colony|
    distinct.joins(:fts_zip_code).where('fts_zip_codes.d_asenta LIKE ?', "%#{alpharize(colony)}%")
  }

  def self.search(params = {})
    zip_codes = all

    if params[:cp].present? || params[:zip_code].present?
      zip_codes = zip_codes.find_by_zip_code(params['cp'] || params['zip_code'])
    end

    zip_codes = zip_codes.find_by_state(params['state']) if params[:state].present?

    zip_codes = zip_codes.find_by_city(params['city']) if params['city'].present?

    zip_codes = zip_codes.find_by_colony(params['colony']) if params[:colony].present?

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

  # Rebuilds the full-text helper table (fts_zip_codes) from every zip code,
  # storing the accent-/case-normalized values the search scopes match against.
  # Uses insert_all in batches to stay within SQLite's bound-parameter limit.
  def self.build_indexes
    all.in_batches(of: 5_000) do |batch|
      rows = batch.map do |item|
        { zip_code_id: item.id }.merge(
          FTS_COLUMNS.index_with { |column| alpharize(item[column].to_s) }
        )
      end
      # fts_zip_codes is a denormalized search index with no validations.
      FtsZipCode.insert_all(rows) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def self.alpharize(text)
    text.downcase.parameterize(separator: ' ')
  end
end
