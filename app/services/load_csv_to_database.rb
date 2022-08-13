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
    UpdateStatesTable.perform! self
    UpdateMunicipalitiesTable.perform! self
    UpdateCitiesTable.perform! self
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

  def notify_load_progress(*args)
    Rails.logger.debug { "Load progress: #{args.inspect}" }
    @listeners[:load_progress]&.call(*args)
  end
end
