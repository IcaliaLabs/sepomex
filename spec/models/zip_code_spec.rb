# frozen_string_literal: true

require 'rails_helper'
require './spec/support/test_helper'

RSpec.describe ZipCode, type: :model do
  include Helper

  context 'validations tests' do
    it { should validate_presence_of(:d_codigo) }
  end

  context 'scopes tests' do
    let!(:zip_code) { FactoryBot.create(:zip_code) }

    it 'should return a zip_code' do
      expect(ZipCode.count).to eq(1)
    end

    it 'search for a wrong zip_code gives empty results' do
      create_cp(%w[57300 21360 81920])
      postcode = '64000'

      expect(ZipCode.find_by_zip_code(postcode)).to be_empty
    end

    it 'search for a valid zip_code gives valid results' do
      postcode = '01000'

      expect(ZipCode.find_by_zip_code(postcode)).to eq([zip_code])
    end

    it 'search for a wrong state gives empty results' do
      create_states(%w[Tamaulipas Sinaloa Tijuana])
      ZipCode.build_indexes
      state = 'Nuevo Leon'

      expect(ZipCode.find_by_state(state)).to be_empty
    end

    it 'search for a valid state gives valid results' do
      state = 'Ciudad de México'

      expect(ZipCode.find_by_state(state)).to eq([zip_code])
    end

    it 'search for a wrong city gives empty results' do
      create_city(%w[Tamaulipas Coahuila Sinaloa])
      city = 'Nuevo Leon'

      expect(ZipCode.find_by_city(city)).to be_empty
    end

    it 'search for a valid city gives valid results' do
      city = 'Ciudad de México'

      expect(ZipCode.find_by_city(city)).to eq([zip_code])
    end

    it 'search for a wrong colony gives empty results' do
      create_colony(%w[Juárez Polanco Centro])
      colony = 'Lomas de Anahuac'

      expect(ZipCode.find_by_colony(colony)).to be_empty
    end

    it 'search for a valid colony gives valid results' do
      colony = 'San Ángel'

      expect(ZipCode.find_by_colony(colony)).to eq([zip_code])
    end
  end
end
