# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Self-contained data refresh** — `rake data:refresh` downloads the latest
  official SEPOMEX export directly (via the new `FetchSepomexExport` service,
  which drives the `CodigoPostal_Exportar.aspx` form postback) and regenerates
  `lib/sepomex_db.csv` in one step. The monthly `data-refresh` workflow now runs
  it with no manually-provisioned mirror URL.
- Documented the **hosted community instance** at `https://sepomex.kurenn.dev`
  (README, docs site, OpenAPI `servers`) as a best-effort alternative to
  self-hosting.

### Changed
- `data-refresh` workflow no longer no-ops without a `SEPOMEX_XML_URL` variable;
  the scheduled run fetches the export itself (a `xml_url` dispatch input still
  overrides it with a specific hosted file).
- Migrated `spec_helper` off deprecated SimpleCov `add_filter`/`add_group`
  (→ `skip`/`group`).

### Removed
- Dropped the stale `lib/sepomex_db.csv.old` snapshot (~14 MB) from the repo.

## [1.0.0] - 2026-07-17

First tagged release — modernizes the stack and adds an MCP server. The public
REST API contract is unchanged.

### Added
- **MCP (Model Context Protocol) server** exposing the postal-code catalog as
  agentic tools, over Streamable HTTP at `/mcp` and stdio via `bin/mcp`. Tools:
  `lookup_zip_code`, `search_zip_codes`, `list_states`, `state_municipalities`,
  `search_cities`.
- `GET /up` health-check endpoint.
- Project `CLAUDE.md` documenting architecture, commands and conventions.

### Changed
- Upgraded to **Rails 8.1** (from 6.1) and **Ruby 3.4.7** (from 3.0.7); Puma 8,
  `sqlite3` 2.x, `config.load_defaults 8.1`.
- Replaced the `pager_api` gem with an internal `Paginatable` concern that keeps
  the exact `meta.pagination` + `Link` / `X-Total-*` response contract.
- Dockerfile base image → `ruby:3.4.7-slim-bookworm` (added `libyaml-dev`).
- Rewrote `bin/dev-entrypoint` without the `on_container` gem.
- Refreshed the README (local + Docker setup, MCP section).

### Removed
- Dropped unmaintained/unused gems: `pager_api`, `pagy`, `byebug`, `debase`,
  `ruby-debug-ide`, `spring`, `on_container`, `google-cloud-secret_manager`.
- Deleted the abandoned `workflows.gcp/` (GCP Cloud Run) pipeline.

### Fixed
- `Time#to_s(:db)` → `to_fs(:db)` in the CSV loader (removed in Rails 8).
- Leftover PostgreSQL-isms on SQLite: `Municipality` `ILIKE` → `LIKE`; removed
  the dead `ZipCode.unaccent`.
- RSpec `fixture_path` → `fixture_paths`; repaired stale factories.

[Unreleased]: https://github.com/IcaliaLabs/sepomex/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/IcaliaLabs/sepomex/releases/tag/v1.0.0
