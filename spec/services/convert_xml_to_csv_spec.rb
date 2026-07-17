# frozen_string_literal: true

require 'rails_helper'
require 'tmpdir'

RSpec.describe ConvertXmlToCsv do
  # Mirrors the official .NET DataSet export: an xsd schema block that must be
  # skipped, then one <table> per record, with the inconsistent tag casing the
  # real file uses (D_mnpio, d_CP, c_CP).
  let(:xml) do
    <<~XML
      <NewDataSet>
      <xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
        <xsd:element name="table"><xsd:complexType/></xsd:element>
      </xsd:schema>
      <table><d_codigo>01000</d_codigo><d_asenta>San Ángel</d_asenta><d_tipo_asenta>Colonia</d_tipo_asenta><D_mnpio>Álvaro Obregón</D_mnpio><d_estado>Ciudad de México</d_estado><d_ciudad>Ciudad de México</d_ciudad><d_CP>01001</d_CP><c_estado>09</c_estado><c_oficina>01001</c_oficina><c_CP></c_CP><c_tipo_asenta>09</c_tipo_asenta><c_mnpio>010</c_mnpio><id_asenta_cpcons>0001</id_asenta_cpcons><d_zona>Urbano</d_zona><c_cve_ciudad>01</c_cve_ciudad></table>
      <table><d_codigo>64000</d_codigo><d_asenta>Centro</d_asenta><d_tipo_asenta>Colonia</d_tipo_asenta><D_mnpio>Monterrey</D_mnpio><d_estado>Nuevo León</d_estado><d_ciudad>Monterrey</d_ciudad><d_CP>64000</d_CP><c_estado>19</c_estado><c_oficina>64000</c_oficina><c_CP></c_CP><c_tipo_asenta>09</c_tipo_asenta><c_mnpio>039</c_mnpio><id_asenta_cpcons>0001</id_asenta_cpcons><d_zona>Urbano</d_zona><c_cve_ciudad>01</c_cve_ciudad></table>
      </NewDataSet>
    XML
  end

  let(:tmpdir) { Dir.mktmpdir }
  let(:xml_path) { File.join(tmpdir, 'CPdescarga.xml') }
  let(:csv_path) { File.join(tmpdir, 'out.csv') }

  before { File.write(xml_path, xml) }
  after { FileUtils.remove_entry(tmpdir) }

  def convert
    described_class.new(xml_path: xml_path, csv_path: csv_path).perform!
  end

  def csv_lines
    File.read(csv_path).split("\r\n")
  end

  it 'converts each <table> record into a pipe-delimited CSV row (skipping the schema)' do
    expect(convert).to eq(2)

    expect(csv_lines.first).to eq(
      '01000|San Ángel|Colonia|Álvaro Obregón|Ciudad de México|Ciudad de México|' \
      '01001|09|01001||09|010|0001|Urbano|01'
    )
    expect(csv_lines.last).to start_with('64000|Centro|Colonia|Monterrey|Nuevo León')
  end

  it 'maps case-inconsistent tags (D_mnpio, d_CP, c_CP) to the correct columns' do
    convert
    fields = csv_lines.first.split('|', -1)

    expect(fields[3]).to eq('Álvaro Obregón') # D_mnpio -> d_mnpio
    expect(fields[6]).to eq('01001')          # d_CP    -> d_cp
    expect(fields[9]).to eq('')               # c_CP    -> c_cp (blank)
  end

  it 'writes CRLF line endings to match the official CSV' do
    convert
    expect(File.binread(csv_path)).to include("Urbano|01\r\n")
  end

  it 'raises when the XML file is missing' do
    expect do
      described_class.new(xml_path: '/no/such/file.xml', csv_path: csv_path).perform!
    end.to raise_error(ArgumentError, /not found/)
  end
end
