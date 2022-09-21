# frozen_string_literal: true

require 'csv'

#= LoadCsvToDatabase
#
# Loads the CSV into the database
class LoadCsvToDatabase
  include Performable

  FILE_PATH = 'lib/sepomex_db.csv'

  def initialize
    @listeners = {}
  end

  def perform!
    read_csv_data
    UpdateZipCodesTable.perform! self
    ZipCode.build_indexes # Create ZipCode indexes
    UpdateStatesTable.perform! self
    UpdateMunicipalitiesTable.perform! self
    UpdateCitiesTable.perform! self
  end

  def on_load_progress(&block)
    @listeners[:load_progress] = block
  end

  protected

  def values
    return @values if @values

    @values = []

    CSV.foreach(FILE_PATH, quote_char: "\x00", col_sep: '|', encoding: 'UTF-8') do |row|
      column_values = row.map { |value| value.blank? ? 'NULL' : "'#{value}'" }
      @values << "(#{column_values.join(', ')})"
    end

    @values = "VALUES #{values.join(', ')}"
  end

  def read_csv_data
    notify_load_progress 'Reading CSV data...'
    values
    notify_load_progress 'Done!'
  end

  delegate :connection, to: ActiveRecord::Base,   prefix: :database
  delegate :execute,    to: :database_connection, prefix: :database

  def notify_load_progress(*args)
    Rails.logger.debug { "Load progress: #{args.inspect}" }
    @listeners[:load_progress]&.call(*args)
  end
end
