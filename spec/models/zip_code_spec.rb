# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ZipCode, type: :model do
  context 'validations tests' do
    it { should validate_presence_of(:d_codigo) }
  end

  context 'scopes tests' do
    let(:params) do
      { d_codigo: '01000',
        d_asenta: 'San Ángel',
        d_tipo_asenta: 'Colonia',
        d_mnpio: 'Álvaro Obregón',
        d_estado: 'Ciudad de México',
        d_ciudad: 'Ciudad de México',
        d_cp: '01001',
        c_estado: '09',
        c_oficina: '01001',
        c_cp: '.',
        c_tipo_asenta: '09',
        c_mnpio: '010',
        id_asenta_cpcons: '0001',
        d_zona: 'Urbano',
        c_cve_ciudad: '01' }
    end

    before(:each) do
      ZipCode.create(params)
    end

    it 'should return a zip_code' do
      expect(ZipCode.count).to eq(1)
    end

    it 'search for a wrong zip_code gives empty results' do
      cp = '64000'
      expect(ZipCode.find_by_zip_code(cp)).to eq([])
    end

    it 'search for a valid zip_code gives valid results' do
      cp = '01000'
      expect(ZipCode.find_by_zip_code(cp)).to eq([ZipCode.last])
    end

    it 'search for a wrong state gives empty results' do
      state = 'Nuevo Leon'
      expect(ZipCode.find_by_state(state)).to eq([])
    end

    it 'search for a valid state gives valid results' do
      state = 'Ciudad de México'
      expect(ZipCode.find_by_state(state)).to eq([ZipCode.last])
    end

    it 'search for a wrong city gives empty results' do
      city = 'Nuevo Leon'
      expect(ZipCode.find_by_city(city)).to eq([])
    end

    it 'search for a valid city gives valid results' do
      city = 'Ciudad de México'
      expect(ZipCode.find_by_city(city)).to eq([ZipCode.last])
    end

    it 'search for a wrong colony gives empty results' do
      colony = 'Lomas de Anahuac'
      expect(ZipCode.find_by_colony(colony)).to eq([])
    end

    it 'search for a valid colony gives valid results' do
      colony = 'San Ángel'
      expect(ZipCode.find_by_colony(colony)).to eq([ZipCode.last])
    end
  end
end
