# frozen_string_literal: true

namespace :data do
  def print_flush(text)
    print "#{text}                                                 \r"
    $stdout.flush
  end

  desc 'Sync data batch'
  task load: %i[environment] do
    if Rails.env.production? && ENV['DEPLOY_NAME'] == 'production' && Municipality.count.zero?
      load_db = LoadCsvToDatabase.new
      load_db.on_load_progress { |message, _data| print_flush message }
      load_db.perform!
    end
  end

  task loadev: %i[environment] do
    if Municipality.count.zero?
      load_db = LoadCsvToDatabase.new
      load_db.on_load_progress { |message, _data| print_flush message }
      load_db.perform!
    end
  end
end
