class CreateFtsZipCodesTable < ActiveRecord::Migration[6.0]
  def up
    execute('CREATE VIRTUAL TABLE fts_zip_codes USING fts4(zip_code_id, d_ciudad, d_estado, d_asenta, d_mnpio)')
  end

  def down
    execute('DROP TABLE IF EXISTS fts_zip_codes')
  end
end
