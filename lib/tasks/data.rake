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

  desc 'Convert the official SEPOMEX XML export into lib/sepomex_db.csv'
  task :import_xml, %i[xml_path] => :environment do |_task, args|
    xml_path = args[:xml_path] || ENV.fetch('XML_PATH', nil)
    if xml_path.blank?
      abort 'Usage: rake "data:import_xml[/path/to/CPdescarga.xml]" (or XML_PATH=... rake data:import_xml)'
    end

    converter = ConvertXmlToCsv.new(xml_path: xml_path)
    converter.on_progress { |rows| print_flush "Converted #{rows} rows..." }
    total = converter.perform!
    puts "\nWrote #{total} rows to lib/sepomex_db.csv"
    puts 'Run `rake data:load` (or data:loadev) to sync the database.'
  end
end
