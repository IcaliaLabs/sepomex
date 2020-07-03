# frozen_string_literal: true

# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'csv'

FILE_PATH = 'lib/sepomex_db.csv'

def create_zipcode(row)
  puts "Creating #{row[0]}. #{row[3]}, #{row[4]}"

  ZipCode.create(d_codigo: row[0],
                 d_asenta: row[1],
                 d_tipo_asenta: row[2],
                 d_mnpio: row[3],
                 d_estado: row[4],
                 d_ciudad: row[5],
                 d_cp: row[6],
                 c_estado: row[7],
                 c_oficina: row[8],
                 c_cp: row[9],
                 c_tipo_asenta: row[10],
                 c_mnpio: row[11],
                 id_asenta_cpcons: row[12],
                 d_zona: row[13],
                 c_cve_ciudad: row[14])
end

def seed_table_zip_code
  puts 'Clearing table zipcodes.'
  ZipCode.delete_all

  puts 'Filling the table zip_codes'
  CSV.foreach(FILE_PATH, col_sep: '|', encoding: 'UTF-8') do |row|
    create_zipcode(row)
  end

  puts 'Zipcode filling finished'
end

# seed_table_zip_code

def seed_table_states
  puts 'Creating states...'

  state_names = ZipCode.pluck(:d_estado).uniq
  state_names.each do |state_name|
    cities_count = ZipCode.where(d_estado: state_name).pluck(:d_mnpio).uniq.count

    State.create(name: state_name, cities_count: cities_count)
  end
  puts 'Done!'
end

# seed_table_states

def seed_table_municipalities
  puts 'Creating municipalities...'

  states = State.all
  states.each do |state|
    municipalities = ZipCode.where(d_estado: state.name)

    municipalities.each do |municipality|
      next if Municipality.find_by_name(municipality.d_mnpio)

      state.municipalities.create(name: municipality.d_mnpio,
                                  municipality_key: municipality.c_mnpio,
                                  zip_code: municipality.d_cp)
    end
  end
  puts 'Done!'
end

# seed_table_municipalities

def seed_table_cities
  puts 'Clearing table cities.'
  City.delete_all

  puts 'Creating cities...'

  states = State.all
  states.each do |state|
    zip_codes_by_state = ZipCode.where(d_estado: state.name)

    zip_codes_by_state.each do |zip_code|
      next if City.find_by_name(zip_code.d_ciudad)

      city_name = 'sin nombre'

      city_name = zip_code.d_ciudad if zip_code.d_ciudad.present?

      state.cities.create(name: city_name)
    end
  end
  puts 'Done!'
end

seed_table_cities
