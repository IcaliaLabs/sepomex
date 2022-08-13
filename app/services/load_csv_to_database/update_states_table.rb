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
        WITH "input_data" AS (
          SELECT DISTINCT ON ("c_estado"::integer)
            "d_estado" AS "name", "c_estado"::integer AS "inegi_state_code"
          FROM "zip_codes"
          ORDER BY "c_estado"::integer
        ), "updates" AS (
          SELECT "s"."id", "i".*
          FROM
            "input_data" AS "i"
            LEFT JOIN "states" AS "s" ON
              "i"."inegi_state_code" = "s"."inegi_state_code"
        )
      SQL
    end

    def insert_missing_states
      database_execute <<~SQL.squish
        #{state_import_cte}
        INSERT INTO "states" ("name", "cities_count", "inegi_state_code")
        SELECT "name", 0, "inegi_state_code"
        FROM "updates" WHERE "id" IS NULL
      SQL
    end

    def update_existing_states
      database_execute <<~SQL.squish
        #{state_import_cte}
        UPDATE "states"
        SET
          "name" = "updates"."name"
        FROM "updates" WHERE "states"."id" = "updates"."id"
      SQL
    end
  end
end
