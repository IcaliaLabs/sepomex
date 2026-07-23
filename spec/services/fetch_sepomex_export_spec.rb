# frozen_string_literal: true

require 'rails_helper'
require 'zlib'

RSpec.describe FetchSepomexExport do
  subject(:service) { described_class.new }

  # Builds a minimal single-member ZIP the way the real export arrives:
  # one deflate-compressed local file entry (flags = 0, method = 8), which is the
  # exact layout FetchSepomexExport#extract_single_member relies on.
  def zip_with(payload, name: 'CPdescarga.xml')
    body = Zlib::Deflate.deflate(payload)[2...-4] # strip zlib header + adler32 -> raw deflate
    [
      "PK\x03\x04",                 # local file header signature
      [20].pack('v'),               # version needed
      [0].pack('v'),                # flags (sizes in header, no data descriptor)
      [8].pack('v'),                # method: deflate
      [0, 0].pack('v2'),            # mod time / date
      [0].pack('V'),                # crc32 (unchecked here)
      [body.bytesize].pack('V'),    # compressed size
      [payload.bytesize].pack('V'), # uncompressed size
      [name.bytesize].pack('v'),    # filename length
      [0].pack('v'),                # extra length
      name.b,
      body
    ].join.b
  end

  describe '#parse_tokens' do
    let(:html) do
      <<~HTML
        <form method="post" action="CodigoPostal_Exportar.aspx">
          <input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE" value="dExampleViewState+/=" />
          <input type="hidden" name="__VIEWSTATEGENERATOR" id="__VIEWSTATEGENERATOR" value="C0FFEE01" />
          <input type="hidden" name="__EVENTVALIDATION" id="__EVENTVALIDATION" value="ev+Validation/=" />
        </form>
      HTML
    end

    it 'extracts the three ASP.NET postback tokens verbatim' do
      expect(service.parse_tokens(html)).to eq(
        '__VIEWSTATE' => 'dExampleViewState+/=',
        '__VIEWSTATEGENERATOR' => 'C0FFEE01',
        '__EVENTVALIDATION' => 'ev+Validation/='
      )
    end

    it 'raises a helpful error when a token is missing (the form changed)' do
      expect { service.parse_tokens('<form></form>') }
        .to raise_error(/__VIEWSTATE.*form may have changed/)
    end
  end

  describe '#extract_single_member' do
    it 'inflates the single XML member from a deflate ZIP' do
      xml = '<NewDataSet><table><d_codigo>64000</d_codigo></table></NewDataSet>'
      expect(service.extract_single_member(zip_with(xml))).to eq(xml)
    end

    it 'raises when the response is not a ZIP (export down / HTML error page)' do
      expect { service.extract_single_member('<html>error</html>') }
        .to raise_error(/did not return a ZIP/)
    end
  end
end
