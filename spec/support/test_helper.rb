# frozen_string_literal: true

module Helper
  def create_states(states)
    states.each do |state|
      FactoryBot.create(:zip_code, d_estado: state)
    end
  end

  def create_cp(postcode)
    postcode.each do |c_p|
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
end
