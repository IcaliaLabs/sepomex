# CLAUDE.md

Guidance for Claude Code (and the roundhouse Rails specialist agents) working in
this repository.

## What this is

Sepomex is an **API-only Rails app** serving Mexico's postal-code (código postal)
catalog — ~154k settlements, 32 states, ~2,475 municipalities, ~660 cities — from
a **bundled SQLite database** loaded from `lib/sepomex_db.csv`. It exposes a
read-only JSON REST API under `/api/v1` and a **Model Context Protocol** server at
`/mcp` (and via `bin/mcp`).

**Stack:** Ruby 3.4.7 · Rails 8.1 (`config.api_only`) · SQLite (`sqlite3` 2.x) ·
Puma · Active Model Serializers (`:json` adapter) · `mcp` gem.

## Building features & fixing bugs

Use **[roundhouse](https://github.com/kurenn/roundhouse)** — a Claude Code plugin
that runs a Rails specialist team (an Opus orchestrator that triages and dispatches
Sonnet specialists) — for implementation work, instead of ad-hoc edits:

- **Features** → `/rails-feature <what you want>` — triages the task and dispatches
  specialists, working **test-first** with conditional security/database gates.
- **Bugs** → `/rails-bugfix <symptom or failing spec>` — root-cause first:
  reproduce, trace, hypothesize, verify, then fix.
- **Targeted work** → call a specialist directly: `/rails-models`,
  `/rails-controllers`, `/rails-services`, `/rails-tests`, `/rails-jobs`. (`/rails-views`
  and `/rails-tailwind` rarely apply — this is an API-only app with no HTML views.)

Whichever path you take, follow the conventions and gotchas below, keep the public
REST contract stable, and leave the spec suite green. When adding an MCP-facing
capability, expose it as a tool under `app/mcp/` that reuses the same models the
REST controllers use.

Install once: `claude plugin marketplace add kurenn/marketplace` then
`claude plugin install roundhouse@kurenn`.

## Commands

```bash
bundle install
bin/rails db:prepare          # create SQLite DB + load db/schema.rb
bin/rake data:loadev          # import the CSV (~154k rows) — dev/test only, runs when empty
bin/rails server              # http://localhost:3000
bundle exec rspec             # test suite (RSpec + FactoryBot + shoulda-matchers)
bundle exec rubocop           # lint (rubocop-rails/-performance/-rspec)
bin/mcp                       # MCP server over stdio (RAILS_ENV=development by default)
```

CI (`.github/workflows`) builds the Dockerfile `testing` + `release` targets and
runs `docker compose run --rm tests`, pushing the release image to Docker Hub
(`icalia/sepomex`) to be deployed to any container host. Production reads
`SECRET_KEY_BASE` from the environment (not baked into the image). The Ruby
version is set **only** in the `Dockerfile` and `.ruby-version`, not in workflow
YAML.

## Architecture

- **Models** (`app/models`): `ZipCode` (a settlement row; `ZipCode.search(params)`
  is the shared query used by both the REST controller and the MCP tool),
  `State`, `Municipality`, `City`, and `FtsZipCode` (a plain search-index table
  populated by `ZipCode.build_indexes`; state/city/colony search joins it).
- **Controllers** (`app/controllers/api/v1`): thin index/show actions. Index
  actions call `paginate(...)`.
- **Pagination** (`app/controllers/concerns/paginatable.rb`): the internal
  `paginate` helper that renders the `meta.pagination` contract + `Link` /
  `X-Total-*` headers. It replaced the removed `pager_api` gem — **its output is
  the public API contract; do not change its shape.**
- **Serializers** (`app/serializers`): AMS with the `:json` adapter → responses
  are `{ "<resource>": ..., "meta": ... }`.
- **CSV loader** (`app/services/load_csv_to_database*`): imports the CSV via
  temp-table + CTE SQL. Invoked by `rake data:load` (prod) / `data:loadev` (dev).
- **MCP** (`app/mcp/sepomex_mcp/`): `SepomexMcp.server` builds an `MCP::Server`
  from the tools in `SepomexMcp::Tools.all`. Tools subclass
  `SepomexMcp::Tools::Base` and **reuse the same models/serializers as REST**.
  Served over HTTP by `McpController` (stateless Streamable HTTP) and over stdio
  by `bin/mcp`.

## Conventions

- All Ruby files start with `# frozen_string_literal: true`.
- Service objects include `Performable` (`.perform!` / `.perform`).
- Keep the **REST response contract stable** (root keys + `meta.pagination`); it
  is covered by request specs in `spec/requests`.
- MCP tools return a text summary **and** `structured_content` (string-keyed,
  serialized via the REST serializers).

## Gotchas

- **SQLite only.** No PostgreSQL. Avoid Postgres-isms (`ILIKE`, `unaccent`,
  extensions). Case-insensitive search uses `lower(...) LIKE` / `alpharize`.
- **`db/structure.sql` is the schema source of truth** (`schema_format = :sql`),
  because `fts_zip_codes` is a SQLite **FTS5** virtual table that `schema.rb`
  can't represent. Prepare databases with `db:prepare` (not `db:test:prepare`,
  which trips the environment check on a SQL schema). Search uses FTS5 `MATCH`
  (token/prefix, accent-folded via the `remove_diacritics` tokenizer).
- `rake data:load` is gated to `Rails.env.production? && ENV['DEPLOY_NAME']=='production'`;
  use `data:loadev` in development/CI.
- `bin/mcp` must keep `$stdout` clean for JSON-RPC — Rails logs go to `$stderr`.
- The database files (`db/*.sqlite3`) are git-ignored; rebuild with the commands
  above.
