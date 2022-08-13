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
      delete_records_no_longer_present_on_input_data
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
            "i"."municipality_key" = "m"."municipality_key"
            AND "i"."state_id" = "m"."state_id"
        ), "deletes" AS (
          SELECT "m"."id"
          FROM "municipalities" AS "m" LEFT JOIN "input_data" AS "i" ON
            "m"."municipality_key" = "i"."municipality_key"
            AND "m"."state_id" = "i"."state_id"
          WHERE "i"."municipality_key" IS NULL AND "i"."state_id" IS NULL
        )
      SQL
    end

    def update_existing_municipalities
      database_execute <<~SQL.squish
        #{municipality_import_cte}
        UPDATE "municipalities"
        SET "name" = "updates"."name", "zip_code" = "updates"."zip_code"
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

    def delete_records_no_longer_present_on_input_data
      database_execute <<~SQL.squish
        #{municipality_import_cte}
        DELETE FROM "municipalities" WHERE "id" IN (SELECT "id" FROM "deletes")
      SQL
    end
  end
end
