# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'zlib'

#= FetchSepomexExport
#
# Downloads the official national zip-code catalog straight from Correos de
# México and writes the raw `CPdescarga.xml` that ConvertXmlToCsv consumes.
#
# The export page (CodigoPostal_Exportar.aspx) is an ASP.NET WebForms page with
# no stable direct-download URL — the file is produced by a form postback. So we
# GET the page to harvest the postback tokens (`__VIEWSTATE`,
# `__VIEWSTATEGENERATOR`, `__EVENTVALIDATION`), then POST them back together with
# "all states" (`cboEdo=00`), the XML format (`rblTipo=xml`) and the image-button
# coordinates (`btnDescarga.x/.y`). The response is a ZIP holding a single
# `CPdescarga.xml`, which we inflate in-process — no `unzip` binary, no extra gem.
#
# This is what makes the monthly `data-refresh` workflow self-contained: no
# manually-provisioned mirror URL, just run it.
class FetchSepomexExport
  include Performable

  EXPORT_URL = 'https://www.correosdemexico.gob.mx/SSLServicios/ConsultaCP/CodigoPostal_Exportar.aspx'
  DEFAULT_OUTPUT = Rails.root.join('tmp/CPdescarga.xml').to_s
  USER_AGENT = 'sepomex-data-refresh (+https://github.com/IcaliaLabs/sepomex)'

  # ASP.NET anti-forgery tokens the postback must echo back verbatim.
  TOKENS = %w[__VIEWSTATE __VIEWSTATEGENERATOR __EVENTVALIDATION].freeze
  ZIP_LOCAL_HEADER = "PK\x03\x04".b

  OPEN_TIMEOUT = 30
  READ_TIMEOUT = 180 # the export is ~3 MB gzipped but the server is slow.

  def initialize(dest: DEFAULT_OUTPUT, url: EXPORT_URL)
    @dest = dest.to_s
    @uri = URI(url)
    @listeners = {}
  end

  # Downloads the export, writes CPdescarga.xml to `dest`, and returns the path.
  def perform!
    xml = extract_single_member(download_zip(form_fields(fetch_tokens)))
    File.binwrite(@dest, xml)
    notify_progress(xml.bytesize)
    @dest
  end

  def on_progress(&block)
    @listeners[:progress] = block
  end

  # -- Testable seams (no network) ------------------------------------------

  # Parses the three ASP.NET postback tokens out of the export page HTML.
  def parse_tokens(html)
    TOKENS.to_h do |name|
      match = html.match(/name="#{Regexp.escape(name)}"[^>]*\svalue="([^"]*)"/)
      raise "SEPOMEX export page is missing #{name}; the form may have changed." unless match

      [name, match[1]]
    end
  end

  # Inflates the single CPdescarga.xml member out of the downloaded ZIP archive.
  def extract_single_member(bytes)
    bytes = bytes.b
    unless bytes.start_with?(ZIP_LOCAL_HEADER)
      raise "SEPOMEX did not return a ZIP (got #{bytes[0, 48].inspect}); the export may be down."
    end

    # Local file header fields: flags, method, compressed size, name/extra lengths.
    flags, method, comp_size, name_len, extra_len = bytes[6, 24].unpack('vv@12V@20vv')

    # Bit 3 means the sizes live in a trailing data descriptor (we rely on the
    # local header); anything but stored/deflate we don't attempt to unpack.
    if flags.anybits?(0x08) || ![0, 8].include?(method)
      raise 'Unexpected ZIP layout from SEPOMEX; extract CPdescarga.xml by hand and use `rake data:import_xml`.'
    end

    compressed = bytes[30 + name_len + extra_len, comp_size]
    method.zero? ? compressed : Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(compressed)
  end

  private

  def fetch_tokens
    response = http.get(@uri.request_uri, 'User-Agent' => USER_AGENT)
    raise "SEPOMEX export page returned HTTP #{response.code}." unless response.is_a?(Net::HTTPSuccess)

    parse_tokens(response.body.force_encoding('ISO-8859-1'))
  end

  def form_fields(tokens)
    tokens.merge(
      '__EVENTTARGET' => '', '__EVENTARGUMENT' => '', '__LASTFOCUS' => '',
      'cboEdo' => '00', 'rblTipo' => 'xml', 'btnDescarga.x' => '12', 'btnDescarga.y' => '12'
    )
  end

  def download_zip(fields)
    response = http.post(
      @uri.request_uri, URI.encode_www_form(fields),
      'User-Agent' => USER_AGENT,
      'Content-Type' => 'application/x-www-form-urlencoded',
      'Referer' => @uri.to_s
    )
    raise "SEPOMEX export download returned HTTP #{response.code}." unless response.is_a?(Net::HTTPSuccess)

    response.body
  end

  def http
    @http ||= Net::HTTP.new(@uri.host, @uri.port).tap do |client|
      client.use_ssl = @uri.scheme == 'https'
      client.open_timeout = OPEN_TIMEOUT
      client.read_timeout = READ_TIMEOUT
    end
  end

  def notify_progress(bytes)
    @listeners[:progress]&.call(bytes)
  end
end
