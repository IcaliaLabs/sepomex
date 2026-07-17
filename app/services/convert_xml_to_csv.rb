# frozen_string_literal: true

require 'nokogiri'

#= ConvertXmlToCsv
#
# Converts the official SEPOMEX zip-code export — a .NET `DataSet` XML with one
# `<table>` element per settlement, downloaded from
# https://www.correosdemexico.gob.mx/SSLServicios/ConsultaCP/CodigoPostal_Exportar.aspx
# — into the pipe-delimited CSV consumed by LoadCsvToDatabase (`lib/sepomex_db.csv`).
#
# The XML is streamed with a SAX parser so the ~67 MB / ~154k-record file never
# has to be held in memory. The XML tag names carry the same 15 fields as the
# CSV but with inconsistent casing (`D_mnpio`, `d_CP`, `c_CP`), so tags are
# matched case-insensitively and written in the CSV's column order.
class ConvertXmlToCsv
  include Performable

  # CSV column order expected by LoadCsvToDatabase::UpdateZipCodesTable::CSV_COLUMNS.
  COLUMNS = %w[
    d_codigo d_asenta d_tipo_asenta d_mnpio d_estado d_ciudad d_cp c_estado
    c_oficina c_cp c_tipo_asenta c_mnpio id_asenta_cpcons d_zona c_cve_ciudad
  ].freeze

  DEFAULT_OUTPUT = Rails.root.join('lib/sepomex_db.csv').to_s

  # The official CSV uses Windows (CRLF) line endings; match it so the output is
  # a byte-for-byte drop-in replacement for lib/sepomex_db.csv.
  ROW_TERMINATOR = "\r\n"

  def initialize(xml_path:, csv_path: DEFAULT_OUTPUT)
    @xml_path = xml_path.to_s
    @csv_path = csv_path.to_s
    @listeners = {}
  end

  # Streams the XML into the CSV and returns the number of rows written.
  def perform!
    raise ArgumentError, "XML file not found: #{@xml_path}" unless File.exist?(@xml_path)

    rows = 0
    File.open(@csv_path, 'w:UTF-8') do |csv|
      handler = RowHandler.new(COLUMNS) do |values|
        csv << values.join('|') << ROW_TERMINATOR
        rows += 1
        notify_progress(rows) if (rows % 10_000).zero?
      end
      File.open(@xml_path, 'r:UTF-8') do |io|
        Nokogiri::XML::SAX::Parser.new(handler).parse_io(io)
      end
    end

    notify_progress(rows)
    rows
  end

  def on_progress(&block)
    @listeners[:progress] = block
  end

  private

  def notify_progress(rows)
    @listeners[:progress]&.call(rows)
  end

  #= ConvertXmlToCsv::RowHandler
  #
  # SAX handler that accumulates each `<table>` record's fields and emits an
  # ordered array of values (one per CSV column) via the given block.
  class RowHandler < Nokogiri::XML::SAX::Document
    RECORD_ELEMENT = 'table'

    def initialize(columns, &emit)
      super()
      @positions = columns.each_with_index.to_h { |column, index| [column, index] }
      @size = columns.size
      @emit = emit
      @record = nil
      @field = nil
      @buffer = +''
    end

    def start_element(name, _attrs = [])
      key = name.downcase
      if key == RECORD_ELEMENT
        @record = Array.new(@size, '')
      elsif @record && @positions.key?(key)
        @field = key
        @buffer = +''
      end
    end

    def characters(string)
      @buffer << string if @field
    end

    def end_element(name)
      key = name.downcase
      if key == RECORD_ELEMENT
        @emit.call(@record) if @record
        @record = nil
      elsif @field == key
        # Guard the pipe-delimited, unquoted CSV against separators in the data.
        @record[@positions[key]] = @buffer.gsub(/[|\r\n]+/, ' ').strip
        @field = nil
      end
    end
  end
end
