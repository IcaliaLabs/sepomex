# frozen_string_literal: true

require 'csv'

#= LoadCsvToDatabase
#
# Loads the CSV into the database
class LoadCsvToDatabase
  include Performable
  
  FILE_PATH = 'lib/sepomex_db.csv'

  def initialize
    @listeners = {}
  end

  def perform!
    update_zip_code_table
    update_states_table
    update_municipalities_table
    update_cities_table
  end

  def on_load_progress(&block)
    @listeners[:load_progress] = block
  end

  protected

  def find_or_create_zipcode(row)
    notify_load_progress "Processing #{row[0]}. #{row[3]}, #{row[4]}..."
    
    ZipCode.create_with(
      d_asenta: row[1],         # Nombre asentamiento
      d_tipo_asenta: row[2],    # Tipo de asentamiento (Catálogo SEPOMEX)
      d_mnpio: row[3],          # Nombre Municipio (INEGI, Marzo 2013)
      d_estado: row[4],         # Nombre Entidad (INEGI, Marzo 2013)
      d_ciudad: row[5],         # Nombre Ciudad (Catálogo SEPOMEX)
      d_cp: row[6],             # Código Postal de la Administración Postal que reparte al asentamiento
      c_estado: row[7],         # Clave Entidad (INEGI, Marzo 2013)
      c_oficina: row[8],        # Código Postal de la Administración Postal que reparte al asentamiento
      c_cp: row[9],             # Campo Vacio
      c_tipo_asenta: row[10],   # Clave Tipo de asentamiento (Catálogo SEPOMEX)
      c_mnpio: row[11],         # Clave Municipio (INEGI, Marzo 2013)
      d_zona: row[13],          # Zona en la que se ubica el asentamiento (Urbano/Rural)
      c_cve_ciudad: row[14]     # Clave Ciudad (Catálogo SEPOMEX)
    ).find_or_create_by(
      d_codigo: row[0],         # Código Postal asentamiento
      id_asenta_cpcons: row[12] # Identificador único del asentamiento (nivel municipal)
    )
  end

  def update_zip_code_table
    notify_load_progress 'Filling the table zip_codes'
  
    CSV.foreach(FILE_PATH, col_sep: '|', encoding: 'UTF-8') do |row|
      find_or_create_zipcode(row)
    end
  
    notify_load_progress 'Zipcode filling finished'
  end

  def update_states_table
    notify_load_progress 'Creating states...'
  
    state_names = ZipCode.pluck(:d_estado).uniq
    state_names.each do |state_name|
      cities_count = ZipCode.where(d_estado: state_name).pluck(:d_mnpio).uniq.count
  
      notify_load_progress "Creating #{state_name}."
      State.find_or_create_by(name: state_name, cities_count: cities_count)
    end
    notify_load_progress 'Done!'
  end
  
  def update_municipalities_table
    states = State.all
    states.each do |state|
      municipalities = ZipCode.where(d_estado: state.name)
  
      municipalities.each do |municipality|
        next if Municipality.find_by_name(municipality.d_mnpio)
  
        notify_load_progress "Creating #{municipality.d_mnpio}."
        state.municipalities.find_or_create_by(name: municipality.d_mnpio,
                                               municipality_key: municipality.c_mnpio,
                                               zip_code: municipality.d_cp)
      end
    end
    notify_load_progress 'Done!'
  end
  
  def update_cities_table
    notify_load_progress 'Creating cities...'
  
    states = State.all
    states.each do |state|
      zip_codes_by_state = ZipCode.where(d_estado: state.name)
  
      zip_codes_by_state.each do |zip_code|
        next if City.find_by_name(zip_code.d_ciudad)
  
        city_name = 'N/A'
  
        city_name = zip_code.d_ciudad if zip_code.d_ciudad.present?
  
        notify_load_progress "Creating #{city_name}."
        state.cities.find_or_create_by(name: city_name)
      end
    end
    notify_load_progress 'Done!'
  end

  def notify_load_progress(*args)
    Rails.logger.debug { "Load progress: #{args.inspect}" }
    @listeners[:load_progress]&.call(*args)
  end
end