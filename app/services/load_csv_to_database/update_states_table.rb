# frozen_string_literal: true

class LoadCsvToDatabase
  #= LoadCsvToDatabase::UpdateStatesTable
  #
  # Updates the states table using the data loaded from the CSV file
  class UpdateStatesTable < BaseUpdateTable
    def perform!
      notify_load_progress 'Updating states table...'
      update_existing_states
      insert_missing_states # highly unlikely!
      notify_load_progress 'Done!'
    end

    protected

    def state_import_cte
      <<~SQL.squish
        WITH "cities_data_except_cmdx" AS (
          #{ZipCode.cities_data_except_cmdx.to_sql}
        ), "cmdx_cities_data" AS (
          #{ZipCode.cmdx_cities_data.to_sql}
        ), "input_source" AS (
          SELECT * FROM "cmdx_cities_data"
          UNION ALL
          SELECT * FROM "cities_data_except_cmdx"
        ), "city_counts" AS (
          SELECT "c_estado", COUNT(*) AS "cities_count"
          FROM "input_source" GROUP BY "c_estado"
        ), "normalized_rows" AS (
          SELECT DISTINCT
            "i"."d_estado" AS "name",
            "c"."cities_count",
            CAST("i"."c_estado" AS INT) AS "inegi_state_code"
          FROM
            "input_source" AS "i"
            INNER JOIN "city_counts" AS "c" ON
              "i"."c_estado" = "c"."c_estado"
        ), "updates" AS (
          SELECT "s"."id", "i".*
          FROM
            "normalized_rows" AS "i"
            LEFT JOIN "states" AS "s" ON
              "i"."inegi_state_code" = "s"."inegi_state_code"
        )
      SQL
    end

    def insert_missing_states
      database_execute <<~SQL.squish
        #{state_import_cte}
        INSERT INTO "states" ("name", "cities_count", "inegi_state_code")
        SELECT "name", "cities_count", "inegi_state_code"
        FROM "updates" WHERE "id" IS NULL
      SQL
    end

    def update_existing_states
      database_execute <<~SQL.squish
        #{state_import_cte}
        UPDATE "states"
        SET "name" = "u"."name", "cities_count" = "u"."cities_count"
        FROM "updates" AS "u" WHERE "states"."id" = "u"."id"
      SQL
    end
  end
end
