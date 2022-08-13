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
        ), "updates" AS (
          SELECT
            "c"."id",
            "i"."name",
            "s"."id" AS "state_id",
            "i"."sepomex_city_code"
          FROM
            "input_source" AS "i"
            INNER JOIN "states" AS "s" ON
              "i"."inegi_state_code" = "s"."inegi_state_code"
            LEFT JOIN "cities" AS "c" ON
              "s"."id" = "c"."state_id"
              AND "i"."sepomex_city_code" = "c"."sepomex_city_code"
          ORDER BY "c"."id" ASC NULLS LAST, "i"."inegi_state_code" ASC, "i"."sepomex_city_code"
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
  end
end
