# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151124153615) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "states", force: true do |t|
    t.string  "name",         null: false
    t.integer "cities_count", null: false
  end

  create_table "zip_codes", force: true do |t|
    t.string   "d_codigo",         null: false
    t.string   "d_asenta",         null: false
    t.string   "d_tipo_asenta",    null: false
    t.string   "d_mnpio",          null: false
    t.string   "d_estado",         null: false
    t.string   "d_ciudad"
    t.string   "d_cp",             null: false
    t.string   "c_estado",         null: false
    t.string   "c_oficina",        null: false
    t.string   "c_cp"
    t.string   "c_tipo_asenta",    null: false
    t.string   "c_mnpio",          null: false
    t.string   "id_asenta_cpcons", null: false
    t.string   "d_zona",           null: false
    t.string   "c_cve_ciudad"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
