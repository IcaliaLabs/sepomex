#encoding: utf-8
require 'bundler/setup'
require 'grape/activerecord/rake'
require 'csv'
require 'pry'

namespace :db do
  task :environment do
    require_relative 'config/env'
  end
end


namespace :db do
  namespace :migrate do
    desc "Migrates the zip codes from the SEPOMEX database"
    task :zip_codes => :environment do
      puts "Here we go..."
      ZipCode.delete_all

      inserts = []
      ActiveRecord::Base.transaction do
        CSV.foreach("./lib/support/sepomex_db.csv", col_sep: "|", :encoding => 'UTF-8') do |row|
          inserts << "(#{row.map {|field| "'#{field}'"}.join(', ')})"
        end

        column_names = ZipCode.columns.map(&:name) - ["id", "created_at", "updated_at"]

        sql_column_names = column_names.join(', ')

        insertion_sql = "INSERT INTO zip_codes (#{sql_column_names}) VALUES #{inserts.join(", ")}"

        ActiveRecord::Base.connection.execute(insertion_sql)

        nil

      end
      puts "Done!"
    end
  end

  namespace :migrate do
    desc "Migrates the states from the zip codes"
    task :states => :environment do
      puts "Creating states..."

      state_names = ZipCode.pluck(:d_estado).uniq
      state_names.each do |state_name|

        cities_count = ZipCode.where(d_estado: state_name).pluck(:d_mnpio).uniq.count

        State.create(name: state_name, cities_count: cities_count)
      end
      puts "Done!"
    end
  end

  namespace :migrate do
    desc "Migrates the municipalities from the zip codes"
    task :municipalities => :environment do
      puts "Creating municipalities..."

      states = State.all
      states.each do |state|
        municipalities = ZipCode.where(d_estado: state.name)

        municipalities.each do |municipality|
          state.municipalities.create(name: municipality.d_mnpio, municipality_key: municipality.c_mnpio, zip_code: municipality.d_cp)
        end

      end
      puts "Done!"

    end
  end

  namespace :migrate do
    desc "Migrates the cities from the zip codes" 
    task cities: :environment do
      puts "Creating cities..."

      states = State.all
      states.each do |state|
        zip_codes_by_state = ZipCode.where(d_estado: state.name)

        zip_codes_by_state.each do |zip_code|
          next if City.find_by_name(zip_code.d_ciudad)
          state.cities.create(name: zip_code.d_ciudad)
        end
      end
      puts "Done!"
    end
  end

  desc "Populates the database"
  task populate_db: ['db:migrate:zip_codes', 'db:migrate:states', 'db:migrate:municipalities', 'db:migrate:cities']
end
