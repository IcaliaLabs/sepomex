class CreateFtsZipCodesTable < ActiveRecord::Migration[6.0]
  def up
    create_table :fts_zip_codes do |t|
      t.integer :zip_code_id, null: false # Código Postal asentamiento
      t.string :d_ciudad
      t.string :d_estado
      t.string :d_asenta
      t.string :d_mnpio
    end
  end

  def down
    execute('DROP TABLE IF EXISTS fts_zip_codes')
  end
end
