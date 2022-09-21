# frozen_string_literal: true

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

  # scope :build_indexes, -> { all.each(&:save) }

  def self.build_indexes
    values = all.map { |item| build_index(item) }
    sql = <<~SQL.strip
      INSERT INTO fts_zip_codes (zip_code_id, d_ciudad, d_estado, d_asenta, d_mnpio)
      VALUES #{values.join(',')}
    SQL
    connection.execute sql
  end

  private

  def self.alpharize(text)
    text.downcase.parameterize(separator: ' ')
  end

  def self.unaccent(column_name, value)
    where("lower(unaccent(#{column_name})) LIKE lower(unaccent(?))", "%#{value}%")
  end

  def self.build_index(item)
    # data = self.attributes.slice('id', 'd_ciudad', 'd_estado', 'd_asenta').values.map do |value|
    #   (value.is_a? Integer) ? value : value.downcase.parameterize(separator: " ")
    # end
    # data.join(',')
    "(#{item.attributes.slice('id', 'd_ciudad', 'd_estado', 'd_asenta', 'd_mnpio').transform_values {
      |v| ("'#{v.to_s.downcase.parameterize(separator: ' ')}'" unless v.is_a? Integer || v.blank?) || v
    }.values.join(",")})"
    # data['zip_code_id'] = data.delete('id')
  end
end
