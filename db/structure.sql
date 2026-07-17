CREATE TABLE IF NOT EXISTS "cities" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "state_id" integer NOT NULL, "sepomex_city_code" integer(2) NOT NULL);
CREATE UNIQUE INDEX "index_cities_on_state_id_and_sepomex_city_code" ON "cities" ("state_id", "sepomex_city_code");
CREATE TABLE IF NOT EXISTS "municipalities" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "municipality_key" varchar NOT NULL, "zip_code" varchar NOT NULL, "state_id" integer);
CREATE UNIQUE INDEX "index_municipalities_on_state_id_and_municipality_key" ON "municipalities" ("state_id", "municipality_key");
CREATE INDEX "index_municipalities_on_state_id" ON "municipalities" ("state_id");
CREATE TABLE IF NOT EXISTS "states" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "cities_count" integer NOT NULL, "inegi_state_code" integer(2) NOT NULL);
CREATE UNIQUE INDEX "index_states_on_inegi_state_code" ON "states" ("inegi_state_code");
CREATE TABLE IF NOT EXISTS "zip_codes" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "d_codigo" varchar NOT NULL, "d_asenta" varchar NOT NULL, "d_tipo_asenta" varchar NOT NULL, "d_mnpio" varchar NOT NULL, "d_estado" varchar NOT NULL, "d_ciudad" varchar, "d_cp" varchar NOT NULL, "c_estado" varchar NOT NULL, "c_oficina" varchar NOT NULL, "c_cp" varchar, "c_tipo_asenta" varchar NOT NULL, "c_mnpio" varchar NOT NULL, "id_asenta_cpcons" varchar NOT NULL, "d_zona" varchar NOT NULL, "c_cve_ciudad" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE VIRTUAL TABLE fts_zip_codes USING fts5( d_ciudad, d_estado, d_asenta, d_mnpio, zip_code_id UNINDEXED, tokenize = 'unicode61 remove_diacritics 2' )
/* fts_zip_codes(d_ciudad,d_estado,d_asenta,d_mnpio,zip_code_id) */;
CREATE TABLE IF NOT EXISTS 'fts_zip_codes_data'(id INTEGER PRIMARY KEY, block BLOB);
CREATE TABLE IF NOT EXISTS 'fts_zip_codes_idx'(segid, term, pgno, PRIMARY KEY(segid, term)) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS 'fts_zip_codes_content'(id INTEGER PRIMARY KEY, c0, c1, c2, c3, c4);
CREATE TABLE IF NOT EXISTS 'fts_zip_codes_docsize'(id INTEGER PRIMARY KEY, sz BLOB);
CREATE TABLE IF NOT EXISTS 'fts_zip_codes_config'(k PRIMARY KEY, v) WITHOUT ROWID;
INSERT INTO "schema_migrations" (version) VALUES
('20260717120000'),
('20220920190651'),
('20220813184618'),
('20220813090827'),
('20200701215345'),
('20200701213016'),
('20200701212647'),
('20200701210819'),
('20200701205801'),
('20200701161814');

