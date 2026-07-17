# frozen_string_literal: true

# Replaces the plain fts_zip_codes helper table with a SQLite FTS5 virtual
# table. The `unicode61 remove_diacritics 2` tokenizer folds case and accents at
# index and query time, so search is accent-insensitive without pre-normalizing
# the stored text. `zip_code_id` is stored UNINDEXED (not full-text-searched) so
# the has_one association can join back to zip_codes.
class ConvertFtsZipCodesToFts5 < ActiveRecord::Migration[8.1]
  def up
    drop_table :fts_zip_codes, if_exists: true

    execute(<<~SQL.squish)
      CREATE VIRTUAL TABLE fts_zip_codes USING fts5(
        d_ciudad, d_estado, d_asenta, d_mnpio,
        zip_code_id UNINDEXED,
        tokenize = 'unicode61 remove_diacritics 2'
      )
    SQL
  end

  def down
    execute('DROP TABLE IF EXISTS fts_zip_codes')

    create_table :fts_zip_codes do |t|
      t.integer :zip_code_id, null: false
      t.string :d_ciudad
      t.string :d_estado
      t.string :d_asenta
      t.string :d_mnpio
    end
  end
end
