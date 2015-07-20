require 'bundler/setup'
require 'grape/activerecord/rake'
require 'csv'
require 'pry'

namespace :db do
  task :environment do
    require './config/env'
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
        CSV.foreach("./lib/support/sepomex_db.csv", col_sep: "|") do |row|
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
end
