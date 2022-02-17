# frozen_string_literal: true

require 'csv'

#= LoadCsvToDatabase
#
# Loads the CSV into the database
class LoadCsvToDatabase
  include Performable

  FILE_PATH = 'lib/sepomex_db.csv'

  def initialize
    @listeners = {}
  end

  def perform!
    update_zip_code_table
    update_states_table
    update_municipalities_table
    update_cities_table
  end

  def on_load_progress(&block)
    @listeners[:load_progress] = block
  end

  protected

  def values
    return @values if @values

    @values = []

    CSV.foreach(FILE_PATH, quote_char: "\x00", col_sep: '|', encoding: 'UTF-8') do |row|
      column_values = row.map { |value| value.blank? ? 'NULL' : "'#{value}'" }
      @values << "(#{column_values.join(', ')})"
    end

    @values = "VALUES #{values.join(', ')}"
  end

  def import_cte
    <<~SQL.squish
      WITH "input_data" AS (
        SELECT * FROM (
          #{values}
        ) AS "input_data" (
          "d_codigo", "d_asenta", "d_tipo_asenta", "d_mnpio", "d_estado", "d_ciudad",
          "d_cp", "c_estado", "c_oficina", "c_cp", "c_tipo_asenta", "c_mnpio",
          "id_asenta_cpcons", "d_zona", "c_cve_ciudad"
        )
      ), "updates" AS (
        SELECT
          "zip_codes"."id",
          "input_data".*,
          COALESCE("zip_codes"."created_at", NOW()) AS "created_at",
          NOW() AS "updated_at"
        FROM
          "input_data"
          LEFT JOIN "zip_codes" ON
            "input_data"."d_codigo" = "zip_codes"."d_codigo"
            AND "input_data"."id_asenta_cpcons" = "zip_codes"."id_asenta_cpcons"
      )
    SQL
  end

  def insert_sql
    <<~SQL.squish
      #{import_cte}
      INSERT INTO "zip_codes" (
        "d_codigo", "d_asenta", "d_tipo_asenta", "d_mnpio", "d_estado", "d_ciudad",
        "d_cp", "c_estado", "c_oficina", "c_cp", "c_tipo_asenta", "c_mnpio",
        "id_asenta_cpcons", "d_zona", "c_cve_ciudad", "created_at", "updated_at"
      ) SELECT
        "d_codigo", "d_asenta", "d_tipo_asenta", "d_mnpio", "d_estado", "d_ciudad",
        "d_cp", "c_estado", "c_oficina", "c_cp", "c_tipo_asenta", "c_mnpio",
        "id_asenta_cpcons", "d_zona", "c_cve_ciudad", "created_at", "updated_at"
      FROM "updates" WHERE "id" IS NULL
    SQL
  end

  def update_sql
    <<~SQL.squish
      #{import_cte}
      UPDATE "zip_codes" SET
        "d_codigo"         = "updates"."d_codigo",
        "d_asenta"         = "updates"."d_asenta",
        "d_tipo_asenta"    = "updates"."d_tipo_asenta",
        "d_mnpio"          = "updates"."d_mnpio",
        "d_estado"         = "updates"."d_estado",
        "d_ciudad"         = "updates"."d_ciudad",
        "d_cp"             = "updates"."d_cp",
        "c_estado"         = "updates"."c_estado",
        "c_oficina"        = "updates"."c_oficina",
        "c_cp"             = "updates"."c_cp",
        "c_tipo_asenta"    = "updates"."c_tipo_asenta",
        "c_mnpio"          = "updates"."c_mnpio",
        "id_asenta_cpcons" = "updates"."id_asenta_cpcons",
        "d_zona"           = "updates"."d_zona",
        "c_cve_ciudad"     = "updates"."c_cve_ciudad",
        "updated_at"       = "updates"."updated_at"
      FROM "updates" WHERE "zip_codes"."id" = "updates"."id"
    SQL
  end

  delegate :connection, to: ActiveRecord::Base,   prefix: :database
  delegate :execute,    to: :database_connection, prefix: :database

  def update_zip_code_table
    notify_load_progress 'Updating the "zip_codes" table...'
    database_execute insert_sql
    database_execute update_sql
    notify_load_progress '..."zip_codes" updating finished'
  end

  def update_states_table
    notify_load_progress 'Creating states...'

    state_names = ZipCode.pluck(:d_estado).uniq
    state_names.each do |state_name|
      cities_count = ZipCode.where(d_estado: state_name).pluck(:d_mnpio).uniq.count

      notify_load_progress "Creating #{state_name}."
      State.find_or_create_by(name: state_name, cities_count: cities_count)
    end
    notify_load_progress 'Done!'
  end

  def update_municipalities_table
    states = State.all
    states.each do |state|
      municipalities = ZipCode.where(d_estado: state.name)

      municipalities.each do |municipality|
        next if Municipality.find_by_name(municipality.d_mnpio)

        notify_load_progress "Creating #{municipality.d_mnpio}."
        state.municipalities.find_or_create_by(name: municipality.d_mnpio,
                                               municipality_key: municipality.c_mnpio,
                                               zip_code: municipality.d_cp)
      end
    end
    notify_load_progress 'Done!'
  end

  def update_cities_table
    notify_load_progress 'Creating cities...'

    states = State.all
    states.each do |state|
      zip_codes_by_state = ZipCode.where(d_estado: state.name)

      zip_codes_by_state.each do |zip_code|
        next if City.find_by_name(zip_code.d_ciudad)

        city_name = 'N/A'

        city_name = zip_code.d_ciudad if zip_code.d_ciudad.present?

        notify_load_progress "Creating #{city_name}."
        state.cities.find_or_create_by(name: city_name)
      end
    end
    notify_load_progress 'Done!'
  end

  def notify_load_progress(*args)
    Rails.logger.debug { "Load progress: #{args.inspect}" }
    @listeners[:load_progress]&.call(*args)
  end
end
