# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SEPOMEX MCP tools' do
  describe SepomexMcp::Tools::LookupZipCode do
    it 'returns the settlements for an exact postal code' do
      FactoryBot.create(:zip_code, d_codigo: '64000', d_asenta: 'Centro',
                                   d_mnpio: 'Monterrey', d_estado: 'Nuevo León')

      response = described_class.call(zip_code: '64000')

      expect(response.error?).to be(false)
      expect(response.structured_content.length).to eq(1)
      expect(response.structured_content.first['d_asenta']).to eq('Centro')
      expect(response.content.first[:text]).to include('64000')
    end

    it 'reports when no settlement matches' do
      response = described_class.call(zip_code: '99999')

      expect(response.structured_content).to be_nil
      expect(response.content.first[:text]).to include('No settlements')
    end
  end

  describe SepomexMcp::Tools::SearchZipCodes do
    it 'filters by partial zip code' do
      FactoryBot.create(:zip_code, d_codigo: '64000')
      FactoryBot.create(:zip_code, d_codigo: '01000')

      response = described_class.call(zip_code: '640')

      expect(response.structured_content.map { |z| z['d_codigo'] }).to eq(['64000'])
    end

    it 'filters by state using the full-text index' do
      FactoryBot.create(:zip_code, d_estado: 'Nuevo León', d_asenta: 'Del Valle')
      FactoryBot.create(:zip_code, d_estado: 'Jalisco')
      ZipCode.build_indexes

      response = described_class.call(state: 'nuevo leon')

      expect(response.structured_content.length).to eq(1)
      expect(response.structured_content.first['d_estado']).to eq('Nuevo León')
    end

    it 'caps results at the requested limit and reports the total' do
      3.times { |i| FactoryBot.create(:zip_code, d_codigo: "0100#{i}") }

      response = described_class.call(zip_code: '0100', limit: 2)

      expect(response.structured_content.length).to eq(2)
      expect(response.content.first[:text]).to include('Found 3')
    end
  end

  describe SepomexMcp::Tools::ListStates do
    it 'lists every state' do
      FactoryBot.create(:state, name: 'Nuevo León')
      FactoryBot.create(:state, name: 'Jalisco')

      response = described_class.call

      expect(response.structured_content.map { |s| s['name'] })
        .to contain_exactly('Nuevo León', 'Jalisco')
    end
  end

  describe SepomexMcp::Tools::StateMunicipalities do
    it 'lists the municipalities of a state' do
      state = FactoryBot.create(:state)
      FactoryBot.create(:municipality, name: 'Monterrey', state: state)
      FactoryBot.create(:municipality, name: 'Guadalupe', state: state)

      response = described_class.call(state_id: state.id)

      expect(response.structured_content.length).to eq(2)
      expect(response.content.first[:text]).to include('2 municipalities')
    end

    it 'reports an unknown state id' do
      response = described_class.call(state_id: 999_999)

      expect(response.structured_content).to be_nil
      expect(response.content.first[:text]).to include('No state')
    end
  end

  describe SepomexMcp::Tools::SearchCities do
    it 'searches cities by name' do
      state = FactoryBot.create(:state)
      FactoryBot.create(:city, name: 'Guadalajara', state: state)
      FactoryBot.create(:city, name: 'Monterrey', state: state)

      response = described_class.call(query: 'guadal')

      expect(response.structured_content.length).to eq(1)
      expect(response.structured_content.first['name']).to eq('Guadalajara')
    end
  end
end
