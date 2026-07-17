# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoadCsvToDatabase do
  before do
    stub_const(
      "#{described_class}::FILE_PATH",
      Rails.root.join('spec/fixtures/files/sepomex_sample.csv').to_s
    )
  end

  it 'loads zip codes and derives states, municipalities and cities from the CSV' do
    described_class.perform!

    aggregate_failures do
      expect(ZipCode.count).to eq(6)
      expect(ZipCode.find_by(d_codigo: '01000').d_asenta).to eq('San Ángel')

      # The sample spans two states (Ciudad de México and Nuevo León).
      expect(State.count).to eq(2)
      expect(Municipality.count).to eq(2)
      expect(City.count).to eq(2)

      # The FTS index is rebuilt as part of the load.
      expect(FtsZipCode.count).to eq(6)
      expect(ZipCode.find_by_state('ciudad de mexico').count(:all)).to eq(3)
    end
  end

  it 'reports load progress to a registered listener' do
    messages = []
    loader = described_class.new
    loader.on_load_progress { |message, _data| messages << message }

    loader.perform!

    expect(messages).to include('Reading CSV data...', 'Done!')
  end
end
