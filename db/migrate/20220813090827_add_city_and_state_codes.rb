# frozen_string_literal: true

class AddCityAndStateCodes < ActiveRecord::Migration[6.0]
  def up
    add_column :states, :inegi_state_code, :integer, limit: 2
    execute <<~SQL.squish
      WITH "data" AS (
        SELECT DISTINCT ON ("c_estado")
          "d_estado" AS "name", "c_estado"::int AS "inegi_state_code"
        FROM "zip_codes"
        WHERE "c_estado" IS NOT NULL
      ), "updates" AS (
        SELECT "s"."id", "d"."inegi_state_code"
        FROM "data" AS "d" INNER JOIN "states" AS "s" ON "d"."name" = "s"."name"
      )
      UPDATE "states" SET "inegi_state_code" =  "updates"."inegi_state_code"
      FROM "updates" WHERE "states"."id" = "updates"."id"
    SQL
    change_column_null :states, :inegi_state_code, false
    add_index :states, :inegi_state_code, unique: true

    add_column :cities, :sepomex_city_code, :integer, limit: 2
    execute <<~SQL.squish
      WITH "data" AS (
        SELECT DISTINCT ON ("c_estado", "c_cve_ciudad")
          "d_ciudad" AS "name",
          "c_estado"::int AS "inegi_state_code",
          "c_cve_ciudad"::int AS "sepomex_city_code"
        FROM "zip_codes"
        WHERE "c_cve_ciudad" IS NOT NULL
        ORDER BY "c_estado", "c_cve_ciudad" ASC
      ), "updates" AS (
        SELECT "c"."id", "d"."sepomex_city_code"
        FROM
          "data" AS "d"
          INNER JOIN "states" AS "s" ON
            "d"."inegi_state_code" = "s"."inegi_state_code"
          INNER JOIN "cities" AS "c" ON
            "d"."name" = "c"."name" AND "s"."id" = "c"."state_id"
        ORDER BY "c"."id", "d"."sepomex_city_code" ASC
      ) UPDATE "cities" SET "sepomex_city_code" =  "updates"."sepomex_city_code"
      FROM "updates" WHERE "cities"."id" = "updates"."id"
    SQL

    # We'll set the city code as not null in another migration after fixing the
    # data on production...

    add_index :cities, %i[state_id sepomex_city_code], unique: true

    add_index :municipalities, %i[state_id municipality_key], unique: true
  end

  def down
    remove_column :states, :inegi_state_code
    remove_column :cities, :sepomex_city_code
  end
end
