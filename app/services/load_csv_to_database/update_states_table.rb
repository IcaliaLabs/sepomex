# frozen_string_literal: true

class LoadCsvToDatabase
  #= LoadCsvToDatabase::UpdateStatesTable
  #
  # Updates the states table using the data loaded from the CSV file
  class UpdateStatesTable < BaseUpdateTable
    def perform!
      notify_load_progress 'Updating states table...'
      update_existing_states
      insert_missing_states
      notify_load_progress 'Done!'
    end

    protected

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

    def insert_missing_states
      database_execute <<~SQL.squish
        #{state_import_cte}
        INSERT INTO "states" ("id", "name", "cities_count")
        SELECT "id_on_import_data", "name", 0
        FROM "updates" WHERE "id" IS NULL
      SQL
    end

    def update_existing_states
      database_execute <<~SQL.squish
        #{state_import_cte}
        UPDATE "states" SET "name" = "updates"."name"
        FROM "updates" WHERE "states"."id" = "updates"."id"
      SQL
    end
  end
end
