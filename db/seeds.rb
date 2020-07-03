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

def seed_table
  puts 'Clearing table zipcodes.'
  ZipCode.delete_all

  CSV.foreach(FILE_PATH, col_sep: '|', encoding: 'UTF-8') do |row|
    create_zipcode(row)
  end

  puts 'Zipcode filling finished'
end

seed_table
