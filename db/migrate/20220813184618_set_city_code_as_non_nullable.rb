# frozen_string_literal: true

#= SetCityCodeAsNonNullable
#
# Finishes changes from db/migrate/20220813090827_add_city_and_state_codes.rb
# and sets the city code as not nullable.
class SetCityCodeAsNonNullable < ActiveRecord::Migration[6.0]
  def change
    change_column_null :cities, :sepomex_city_code, false
  end
end
