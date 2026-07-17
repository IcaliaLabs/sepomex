# frozen_string_literal: true

require 'rails_helper'

# Behavioural coverage for the SQLite FTS5 zip-code search.
RSpec.describe 'ZipCode FTS5 search' do
  it 'matches accent- and case-insensitively' do
    FactoryBot.create(:zip_code, d_estado: 'Nuevo León', d_mnpio: 'Monterrey',
                                 d_ciudad: 'Monterrey', d_asenta: 'Centro')
    ZipCode.build_indexes

    expect(ZipCode.find_by_state('nuevo leon').count(:all)).to eq(1)
    expect(ZipCode.find_by_state('LEÓN').count(:all)).to eq(1)
  end

  it 'matches by token prefix' do
    FactoryBot.create(:zip_code, d_ciudad: 'Guadalajara', d_mnpio: 'Guadalajara',
                                 d_estado: 'Jalisco', d_asenta: 'Centro')
    ZipCode.build_indexes

    expect(ZipCode.find_by_city('guadal').count(:all)).to eq(1)
  end

  it 'combines filters into a single MATCH (state AND city)' do
    FactoryBot.create(:zip_code, d_estado: 'Nuevo León', d_mnpio: 'Monterrey',
                                 d_ciudad: 'Monterrey', d_asenta: 'Del Valle')
    FactoryBot.create(:zip_code, d_estado: 'Jalisco', d_mnpio: 'Guadalajara',
                                 d_ciudad: 'Guadalajara', d_asenta: 'Centro')
    ZipCode.build_indexes

    result = ZipCode.search({ 'state' => 'nuevo leon', 'city' => 'monterrey' }.with_indifferent_access)

    expect(result.count(:all)).to eq(1)
    expect(result.first.d_estado).to eq('Nuevo León')
  end

  it 'returns nothing for a non-matching term' do
    FactoryBot.create(:zip_code, d_estado: 'Jalisco')
    ZipCode.build_indexes

    expect(ZipCode.find_by_state('nuevo leon')).to be_empty
  end
end
