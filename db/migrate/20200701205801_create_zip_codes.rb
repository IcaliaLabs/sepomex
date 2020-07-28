class CreateZipCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :zip_codes do |t|
      t.string :d_codigo,null: false # Código Postal asentamiento
      t.string :d_asenta,null: false # Nombre asentamiento
      t.string :d_tipo_asenta,null: false # Tipo de asentamiento (Catálogo SEPOMEX)
      t.string :d_mnpio,null: false # Nombre Municipio (INEGI, Marzo 2013)
      t.string :d_estado,null: false # Nombre Entidad (INEGI, Marzo 2013)
      t.string :d_ciudad # Nombre Ciudad (Catálogo SEPOMEX)
      t.string :d_cp,null: false # Código Postal de la Administración Postal que reparte al asentamiento
      t.string :c_estado,null: false # Clave Entidad (INEGI, Marzo 2013)
      t.string :c_oficina,null: false # Código Postal de la Administración Postal que reparte al asentamiento
      t.string :c_cp # Campo Vacio
      t.string :c_tipo_asenta,null: false # Clave Tipo de asentamiento (Catálogo SEPOMEX)
      t.string :c_mnpio,null: false # Clave Municipio (INEGI, Marzo 2013)
      t.string :id_asenta_cpcons,null: false # Identificador único del asentamiento (nivel municipal)
      t.string :d_zona,null: false # Zona en la que se ubica el asentamiento (Urbano/Rural)
      t.string :c_cve_ciudad # Clave Ciudad (Catálogo SEPOMEX)

      t.timestamps
    end
  end
end
