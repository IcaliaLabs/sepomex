# frozen_string_literal: true

class ZipCode < ApplicationRecord
  validates :d_codigo, presence: true

  default_scope { order(:id) }

  scope :find_by_zip_code, lambda { |cp|
    where('lower(d_codigo) LIKE lower(?)', "%#{cp}%")
  }

  scope :find_by_state, lambda { |state|
    unaccent('d_estado', state)
  }

  scope :find_by_city, lambda { |city|
    where("lower(unaccent(d_ciudad)) LIKE lower(unaccent(?))
          OR lower(unaccent(d_mnpio)) LIKE lower(unaccent(?))", "%#{city}%", "%#{city}%")
  }

  scope :find_by_colony, lambda { |colony|
    unaccent('d_asenta', colony)
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

  after_commit :build_index

  scope :build_indexes, -> { all.each(&:save) }

  private

  def self.unaccent(column_name, value)
    where("lower(unaccent(#{column_name})) LIKE lower(unaccent(?))", "%#{value}%")
  end

  def build_index
    # data = self.attributes.slice('id', 'd_ciudad', 'd_estado', 'd_asenta').values.map do |value|
    #   (value.is_a? Integer) ? value : value.downcase.parameterize(separator: " ")
    # end
    # data.join(',')
    data = self.attributes.slice('id', 'd_ciudad', 'd_estado', 'd_asenta')
                     .transform_values { |v| v.to_s.downcase.parameterize(separator: ' ') }
    data['zip_code_id'] = data.delete('id').to_i
    FtsZipCode.find_or_create_by(data)
  end
end
