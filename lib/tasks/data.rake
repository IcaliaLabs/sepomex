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

  def import_xml_file(xml_path)
    converter = ConvertXmlToCsv.new(xml_path: xml_path)
    converter.on_progress { |rows| print_flush "Converted #{rows} rows..." }
    total = converter.perform!
    puts "\nWrote #{total} rows to lib/sepomex_db.csv"
    puts 'Run `rake data:load` (or data:loadev) to sync the database.'
  end

  desc 'Convert an already-downloaded SEPOMEX XML export into lib/sepomex_db.csv'
  task :import_xml, %i[xml_path] => :environment do |_task, args|
    xml_path = args[:xml_path] || ENV.fetch('XML_PATH', nil)
    if xml_path.blank?
      abort 'Usage: rake "data:import_xml[/path/to/CPdescarga.xml]" (or XML_PATH=... rake data:import_xml)'
    end

    import_xml_file(xml_path)
  end

  desc 'Download the latest official SEPOMEX export and regenerate lib/sepomex_db.csv'
  task refresh: :environment do
    require 'tmpdir'

    Dir.mktmpdir('sepomex-refresh') do |dir|
      xml_path = File.join(dir, 'CPdescarga.xml')
      fetch = FetchSepomexExport.new(dest: xml_path)
      fetch.on_progress { |bytes| print_flush "Downloaded #{bytes} bytes of XML..." }
      fetch.perform!

      import_xml_file(xml_path)
    end
  end
end
