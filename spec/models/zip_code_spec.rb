# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ZipCode, type: :model do
  context 'validations tests' do
    it { should validate_presence_of(:d_codigo) }
  end

  context 'scopes tests' do
    let!(:zip_code) { FactoryBot.create(:zip_code) }

    it 'should return a zip_code' do
      expect(ZipCode.count).to eq(1)
    end

    it 'search for a wrong zip_code gives empty results' do
      FactoryBot.create(:zip_code, d_cp: '57300')
      FactoryBot.create(:zip_code, d_cp: '21360')
      FactoryBot.create(:zip_code, d_cp: '81920')

      cp = '64000'

      expect(ZipCode.find_by_zip_code(cp)).to be_empty
    end

    it 'search for a valid zip_code gives valid results' do
      cp = '01000'

      expect(ZipCode.find_by_zip_code(cp)).to eq([ZipCode.last])
    end

    it 'search for a wrong state gives empty results' do
      FactoryBot.create(:zip_code, d_estado: 'Tamaulipas')
      FactoryBot.create(:zip_code, d_estado: 'Coahuila')
      FactoryBot.create(:zip_code, d_estado: 'Sinaloa')

      state = 'Nuevo Leon'

      expect(ZipCode.find_by_state(state)).to be_empty
    end

    it 'search for a valid state gives valid results' do
      state = 'Ciudad de México'

      expect(ZipCode.find_by_state(state)).to eq([ZipCode.last])
    end

    it 'search for a wrong city gives empty results' do
      FactoryBot.create(:zip_code, d_ciudad: 'Tamaulipas')
      FactoryBot.create(:zip_code, d_ciudad: 'Coahuila')
      FactoryBot.create(:zip_code, d_ciudad: 'Sinaloa')

      city = 'Nuevo Leon'

      expect(ZipCode.find_by_city(city)).to be_empty
    end

    it 'search for a valid city gives valid results' do
      city = 'Ciudad de México'

      expect(ZipCode.find_by_city(city)).to eq([ZipCode.last])
    end

    it 'search for a wrong colony gives empty results' do
      FactoryBot.create(:zip_code, d_asenta: 'Juárez')
      FactoryBot.create(:zip_code, d_asenta: 'Polanco')
      FactoryBot.create(:zip_code, d_asenta: 'Centro')

      colony = 'Lomas de Anahuac'

      expect(ZipCode.find_by_colony(colony)).to be_empty
    end

    it 'search for a valid colony gives valid results' do
      colony = 'San Ángel'

      expect(ZipCode.find_by_colony(colony)).to eq([ZipCode.last])
    end
  end
end
