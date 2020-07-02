# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_200_701_215_345) do
  create_table 'cities', force: :cascade do |t|
    t.string 'name', null: false
    t.integer 'state_id', null: false
  end

  create_table 'municipalities', force: :cascade do |t|
    t.string 'name', null: false
    t.string 'municipality_key', null: false
    t.string 'zip_code', null: false
    t.integer 'state_id'
    t.index ['state_id'], name: 'index_municipalities_on_state_id'
  end

  create_table 'states', force: :cascade do |t|
    t.string 'name', null: false
    t.integer 'cities_count', null: false
  end

  create_table 'zip_codes', force: :cascade do |t|
    t.string 'd_codigo', null: false
    t.string 'd_asenta', null: false
    t.string 'd_tipo_asenta', null: false
    t.string 'd_mnpio', null: false
    t.string 'd_estado', null: false
    t.string 'd_ciudad'
    t.string 'd_cp', null: false
    t.string 'c_estado', null: false
    t.string 'c_oficina', null: false
    t.string 'c_cp'
    t.string 'c_tipo_asenta', null: false
    t.string 'c_mnpio', null: false
    t.string 'id_asenta_cpcons', null: false
    t.string 'd_zona', null: false
    t.string 'c_cve_ciudad'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end
end
