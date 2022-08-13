# frozen_string_literal: true

class LoadCsvToDatabase
  #= LoadCsvToDatabase::UpdateMunicipalitiesTable
  #
  # Updates the municipalities table using the data loaded from the CSV file
  class UpdateMunicipalitiesTable < BaseUpdateTable
    def perform!
      notify_load_progress 'Updating municipalities table...'
      update_existing_municipalities
      insert_missing_municipalities
      notify_load_progress 'Done!'
    end

    protected

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
  end
end
