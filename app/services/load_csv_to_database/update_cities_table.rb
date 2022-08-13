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

      delete_cities_not_in_csv # and some boroughs, villages incorrectly
      # added as cities by previous versions of the data loader

      notify_load_progress 'Done!'
    end

    protected

    def city_import_cte
      <<~SQL.squish
        WITH "input_source" AS (
          (
            SELECT DISTINCT ON ("c_estado"::int, "c_cve_ciudad"::int)
              "d_ciudad" AS "name",
              "c_estado"::int AS "inegi_state_code",
              "c_cve_ciudad"::int AS "sepomex_city_code"
            FROM "zip_codes"
            WHERE "c_estado" <> '09' AND "c_cve_ciudad" IS NOT NULL
            ORDER BY "c_estado"::int, "c_cve_ciudad"::int
          ) UNION ALL (
            SELECT DISTINCT ON ("c_estado"::int)
              "d_ciudad" AS "name",
              "c_estado"::int AS "inegi_state_code",
              "c_cve_ciudad"::int AS "sepomex_city_code"
            FROM "zip_codes"
            WHERE "c_estado" = '09' AND "c_cve_ciudad" IS NOT NULL
            ORDER BY "c_estado"::int, "c_cve_ciudad"::int
          )
        ), "normalized_rows" AS (
          SELECT
            "i"."name",
            "s"."id" AS "state_id",
            "i"."sepomex_city_code"
          FROM
            "input_source" AS "i"
            INNER JOIN "states" AS "s" ON
              "i"."inegi_state_code" = "s"."inegi_state_code"
        ), "updates" AS (
          SELECT "c"."id", "i".*
          FROM
            "normalized_rows" AS "i"
            LEFT JOIN "cities" AS "c" ON
              "i"."state_id" = "c"."state_id"
              AND "i"."sepomex_city_code" = "c"."sepomex_city_code"
        ), "deletes" AS (
          SELECT "c"."id"
          FROM
            "normalized_rows" AS "i"
            RIGHT JOIN "cities" AS "c" ON
              "i"."state_id" = "c"."state_id"
              AND "i"."sepomex_city_code" = "c"."sepomex_city_code"
          WHERE "i"."sepomex_city_code" IS NULL
        )
      SQL
    end

    def update_existing_cities
      database_execute <<~SQL.squish
        #{city_import_cte}
        UPDATE "cities"
        SET "name" = "updates"."name"
        FROM "updates" WHERE "cities"."id" = "updates"."id"
      SQL
    end

    def insert_missing_cities
      database_execute <<~SQL.squish
        #{city_import_cte}
        INSERT INTO "cities" ("name", "state_id", "sepomex_city_code")
        SELECT "name", "state_id", "sepomex_city_code"
        FROM "updates" WHERE "id" IS NULL
      SQL
    end

    def delete_cities_not_in_csv
      database_execute <<~SQL.squish
        #{city_import_cte}
        DELETE FROM "cities"
        WHERE "id" IN (SELECT "id" FROM "deletes")
      SQL
    end
  end
end
