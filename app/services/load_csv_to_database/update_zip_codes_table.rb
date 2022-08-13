# frozen_string_literal: true

class LoadCsvToDatabase
  #= LoadCsvToDatabase::UpdateZipCodesTable
  #
  # Updates the zip codes table using the data loaded from the CSV file
  # NOTE: In reality, the zip codes table contains a list of settlements, not
  # zip codes.
  class UpdateZipCodesTable < BaseUpdateTable
    def perform!
      notify_load_progress 'Updating zip codes table...'
      update_existing_records
      add_missing_records
      delete_records_no_longer_present_on_input_data
      notify_load_progress 'Done!'
    end

    protected

    def values
      data_loader.send :values
    end

    def zip_codes_import_cte
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
            "z"."id",
            "i".*,
            COALESCE("z"."created_at", NOW()) AS "created_at",
            NOW() AS "updated_at"
          FROM "input_data" AS "i" LEFT JOIN "zip_codes" AS "z" ON
            "i"."c_estado" = "z"."c_estado"
            AND "i"."c_mnpio" = "z"."c_mnpio"
            AND "i"."id_asenta_cpcons" = "z"."id_asenta_cpcons"
        ), "deletes" AS (
          SELECT DISTINCT "z"."id"
          FROM "zip_codes" AS "z" LEFT JOIN "input_data" AS "i" ON
            "z"."c_estado" = "i"."c_estado"
            AND "z"."c_mnpio" = "i"."c_mnpio"
            AND "z"."id_asenta_cpcons" = "i"."id_asenta_cpcons"
          WHERE "i"."d_codigo" IS NULL
        )
      SQL
    end

    def add_missing_records
      database_execute <<~SQL.squish
        #{zip_codes_import_cte}
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

    def update_existing_records
      database_execute <<~SQL.squish
        #{zip_codes_import_cte}
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

    def delete_records_no_longer_present_on_input_data
      database_execute <<~SQL.squish
        #{zip_codes_import_cte}
        DELETE FROM "zip_codes" WHERE "id" IN (SELECT "id" FROM "deletes")
      SQL
    end
  end
end
