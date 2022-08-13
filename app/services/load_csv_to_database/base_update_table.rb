# frozen_string_literal: true

class LoadCsvToDatabase
  #= LoadCsvToDatabase::BaseUpdateTable
  #
  # Base class used to update tables using the data loaded from the CSV file
  class BaseUpdateTable
    include Performable

    attr_reader :data_loader

    delegate :database_execute, to: :data_loader

    def initialize(data_loader)
      @data_loader = data_loader
    end

    protected

    def notify_load_progress(*args)
      data_loader.send(:notify_load_progress, *args)
    end
  end
end
