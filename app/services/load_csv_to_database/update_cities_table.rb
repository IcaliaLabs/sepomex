# frozen_string_literal: true

class LoadCsvToDatabase
  #= LoadCsvToDatabase::UpdateCitiesTable
  #
  # Updates the cities table using the data loaded from the CSV file
  class UpdateCitiesTable < BaseUpdateTable
    def perform!
      notify_load_progress 'Creating cities...'
      update_existing_cities
      insert_missing_cities
      notify_load_progress 'Done!'
    end

    protected

    def city_import_cte
      <<~SQL.squish
        WITH "input_source" AS (
          SELECT DISTINCT ON ("c_estado", "c_cve_ciudad")
            "d_ciudad" AS "name", "d_estado" AS "state_name"
          FROM "zip_codes"
          WHERE "c_cve_ciudad" IS NOT NULL
          ORDER BY "c_estado", "c_cve_ciudad" ASC
        ), "input_data" AS (
          SELECT DISTINCT "i"."name", "s"."id" AS "state_id"
          FROM "input_source" AS "i" INNER JOIN "states" AS "s" ON
            "i"."state_name" = "s"."name"
        ), "updates" AS (
          SELECT "c"."id", "i".*
          FROM "input_data" AS "i" LEFT JOIN "cities" AS "c" ON
            "i"."name" = "c"."name" AND "i"."state_id" = "c"."state_id"
        )
      SQL
    end

    def update_existing_cities
      database_execute <<~SQL.squish
        #{city_import_cte}
        UPDATE "cities" SET
          "name" = "updates"."name", "state_id" = "updates"."state_id"
        FROM "updates" WHERE "cities"."id" = "updates"."id"
      SQL
    end

    def insert_missing_cities
      database_execute <<~SQL.squish
        #{city_import_cte}
        INSERT INTO "cities" ("name", "state_id")
        SELECT "name", "state_id"
        FROM "updates"
        WHERE "id" IS NULL
        ORDER BY "state_id", "name" ASC
      SQL
    end
  end
end
