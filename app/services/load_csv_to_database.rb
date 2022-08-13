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

  def insert_zip_codes
    database_execute <<~SQL.squish
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

  def update_zip_codes
    database_execute <<~SQL.squish
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
    insert_zip_codes
    update_zip_codes
    notify_load_progress '..."zip_codes" updating finished'
  end

  def state_import_cte
    <<~SQL.squish
      WITH "input_data" AS (
        SELECT "c_estado"::integer AS "id", "d_estado" AS "name"
        FROM "zip_codes"
        GROUP BY "d_estado", "c_estado"
        ORDER BY "c_estado"::integer
      ), "updates" AS (
        SELECT
          "states"."id",
          "input_data"."name",
          "input_data"."id" as "id_on_import_data"
        FROM
          "input_data"
          LEFT JOIN "states" ON "input_data"."id" = "states"."id"
      )
    SQL
  end

  def insert_states
    database_execute <<~SQL.squish
      #{state_import_cte}
      INSERT INTO "states" ("id", "name", "cities_count")
      SELECT "id_on_import_data", "name", 0
      FROM "updates" WHERE "id" IS NULL
    SQL
  end

  def update_states
    database_execute <<~SQL.squish
      #{state_import_cte}
      UPDATE "states" SET "name" = "updates"."name"
      FROM "updates" WHERE "states"."id" = "updates"."id"
    SQL
  end

  def update_states_table
    notify_load_progress 'Creating states...'
    insert_states
    update_states
    notify_load_progress 'Done!'
  end

  def municipality_import_cte
    <<~SQL.squish
      WITH "input_data_source" AS (
        SELECT DISTINCT ON ("c_estado", "c_mnpio")
          "d_mnpio" AS "name",
          "c_mnpio" AS "municipality_key",
          "d_cp" AS "zip_code",
          "d_estado" AS "state_name"
        FROM "zip_codes" ORDER BY "c_estado", "c_mnpio" ASC, "d_cp" DESC
      ), "input_data" AS (
        SELECT
          "input_data_source"."name",
          "input_data_source"."municipality_key",
          "input_data_source"."zip_code",
          "states"."id" AS "state_id"
        FROM
          "input_data_source"
          INNER JOIN "states" ON "input_data_source"."state_name" = "states"."name"
      ), "updates" AS (
        SELECT "m"."id", "i".*
        FROM "input_data" AS "i" LEFT JOIN "municipalities" AS "m" ON
          "i"."name" = "m"."name"
          AND "i"."municipality_key" = "m"."municipality_key"
          AND "i"."state_id" = "m"."state_id"
      )
    SQL
  end

  def update_existing_municipalities
    database_execute <<~SQL.squish
      #{municipality_import_cte}
      UPDATE "municipalities" SET
        "name" = "updates"."name",
        "municipality_key" = "updates"."municipality_key",
        "zip_code" = "updates"."zip_code",
        "state_id" = "updates"."state_id"
      FROM "updates" WHERE "municipalities"."id" = "updates"."id"
    SQL
  end

  def insert_missing_municipalities
    database_execute <<~SQL.squish
      #{municipality_import_cte}
      INSERT INTO "municipalities" ("name", "municipality_key", "zip_code", "state_id")
      SELECT "name", "municipality_key", "zip_code", "state_id"
      FROM "updates"
      WHERE "id" IS NULL
      ORDER BY "state_id", "municipality_key" ASC
    SQL
  end

  def update_municipalities_table
    notify_load_progress 'Updating municipalities table...'
    update_existing_municipalities
    insert_missing_municipalities
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
