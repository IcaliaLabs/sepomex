CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "zip_codes" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "d_codigo" varchar NOT NULL, "d_asenta" varchar NOT NULL, "d_tipo_asenta" varchar NOT NULL, "d_mnpio" varchar NOT NULL, "d_estado" varchar NOT NULL, "d_ciudad" varchar, "d_cp" varchar NOT NULL, "c_estado" varchar NOT NULL, "c_oficina" varchar NOT NULL, "c_cp" varchar, "c_tipo_asenta" varchar NOT NULL, "c_mnpio" varchar NOT NULL, "id_asenta_cpcons" varchar NOT NULL, "d_zona" varchar NOT NULL, "c_cve_ciudad" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE sqlite_sequence(name,seq);
CREATE TABLE IF NOT EXISTS "municipalities" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "municipality_key" varchar NOT NULL, "zip_code" varchar NOT NULL, "state_id" integer);
CREATE INDEX "index_municipalities_on_state_id" ON "municipalities" ("state_id");
CREATE TABLE IF NOT EXISTS "states" ("id" integer NOT NULL PRIMARY KEY, "name" varchar NOT NULL, "cities_count" integer NOT NULL, "inegi_state_code" integer(2) NOT NULL);
CREATE UNIQUE INDEX "index_states_on_inegi_state_code" ON "states" ("inegi_state_code");
CREATE UNIQUE INDEX "index_municipalities_on_state_id_and_municipality_key" ON "municipalities" ("state_id", "municipality_key");
CREATE TABLE IF NOT EXISTS "cities" ("id" integer NOT NULL PRIMARY KEY, "name" varchar NOT NULL, "state_id" integer NOT NULL, "sepomex_city_code" integer(2) NOT NULL);
CREATE UNIQUE INDEX "index_cities_on_state_id_and_sepomex_city_code" ON "cities" ("state_id", "sepomex_city_code");
CREATE VIRTUAL TABLE fts_zip_codes USING fts4(zip_code_id, d_ciudad, d_estado, d_asenta, d_mnpio)
/* fts_zip_codes(zip_code_id,d_ciudad,d_estado,d_asenta,d_mnpio) */;
CREATE TABLE IF NOT EXISTS 'fts_zip_codes_content'(docid INTEGER PRIMARY KEY, 'c0zip_code_id', 'c1d_ciudad', 'c2d_estado', 'c3d_asenta', 'c4d_mnpio');
CREATE TABLE IF NOT EXISTS 'fts_zip_codes_segments'(blockid INTEGER PRIMARY KEY, block BLOB);
CREATE TABLE IF NOT EXISTS 'fts_zip_codes_segdir'(level INTEGER,idx INTEGER,start_block INTEGER,leaves_end_block INTEGER,end_block INTEGER,root BLOB,PRIMARY KEY(level, idx));
CREATE TABLE IF NOT EXISTS 'fts_zip_codes_docsize'(docid INTEGER PRIMARY KEY, size BLOB);
CREATE TABLE IF NOT EXISTS 'fts_zip_codes_stat'(id INTEGER PRIMARY KEY, value BLOB);
INSERT INTO "schema_migrations" (version) VALUES
('20200701161814'),
('20200701205801'),
('20200701210819'),
('20200701212647'),
('20200701213016'),
('20200701215345'),
('20220813090827'),
('20220813184618'),
('20220920190651');


