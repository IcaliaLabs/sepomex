# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ZipCode, type: :model do
  context 'validations tests' do
    it { should validate_presence_of(:d_codigo) }
  end

  def create_states(states)
    states.each do |state|
      FactoryBot.create(:zip_code, d_estado: state)
    end
  end

  def create_cp(cp)
    cp.each do |c_p|
      FactoryBot.create(:zip_code, d_cp: c_p)
    end
  end

  def create_city(city)
    city.each do |cities|
      FactoryBot.create(:zip_code, d_ciudad: cities)
    end
  end

  def create_colony(colony)
    colony.each do |col|
      FactoryBot.create(:zip_code, d_asenta: col)
    end
  end

  context 'scopes tests' do
    let!(:zip_code) { FactoryBot.create(:zip_code) }

    it 'should return a zip_code' do
      expect(ZipCode.count).to eq(1)
    end

    it 'search for a wrong zip_code gives empty results' do
      create_cp(%w[57300 21360 81920])
      cp = '64000'

      expect(ZipCode.find_by_zip_code(cp)).to be_empty
    end

    it 'search for a valid zip_code gives valid results' do
      cp = '01000'

      expect(ZipCode.find_by_zip_code(cp)).to eq([ZipCode.last])
    end

    it 'search for a wrong state gives empty results' do
      create_states(%w[Tamaulipas Sinaloa Tijuana])
      state = 'Nuevo Leon'

      expect(ZipCode.find_by_state(state)).to be_empty
    end

    it 'search for a valid state gives valid results' do
      state = 'Ciudad de México'

      expect(ZipCode.find_by_state(state)).to eq([ZipCode.last])
    end

    it 'search for a wrong city gives empty results' do
      create_city(%w[Tamaulipas Coahuila Sinaloa])
      city = 'Nuevo Leon'

      expect(ZipCode.find_by_city(city)).to be_empty
    end

    it 'search for a valid city gives valid results' do
      city = 'Ciudad de México'

      expect(ZipCode.find_by_city(city)).to eq([ZipCode.last])
    end

    it 'search for a wrong colony gives empty results' do
      create_colony(%w[Juárez Polanco Centro])
      colony = 'Lomas de Anahuac'

      expect(ZipCode.find_by_colony(colony)).to be_empty
    end

    it 'search for a valid colony gives valid results' do
      colony = 'San Ángel'

      expect(ZipCode.find_by_colony(colony)).to eq([ZipCode.last])
    end
  end
end
