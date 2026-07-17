<div align="center">

# 📮 Sepomex

### The open REST **and** MCP API for Mexico's postal codes

**Every Mexican zip code, state, municipality, city and settlement — one bundled SQLite database, no API key, no rate limit.**

[![Release](https://img.shields.io/github/v/release/IcaliaLabs/sepomex?color=c2693d&label=release)](https://github.com/IcaliaLabs/sepomex/releases)
[![Build](https://img.shields.io/github/actions/workflow/status/IcaliaLabs/sepomex/ci-and-cd.yml?branch=main&color=c2693d&label=build)](https://github.com/IcaliaLabs/sepomex/actions)
[![Ruby](https://img.shields.io/badge/Ruby-3.4.7-c2693d)](.ruby-version)
[![Rails](https://img.shields.io/badge/Rails-8.1-c2693d)](Gemfile)
[![MCP](https://img.shields.io/badge/MCP-ready-c2693d)](#-mcp-server)
[![License](https://img.shields.io/badge/License-MIT-c2693d)](LICENSE)

[Quick start](#-quick-start) · [Querying the API](#-querying-the-api) · [MCP server](#-mcp-server) · [Development](#️-development) · [Architecture](#-architecture)

</div>

---

## Why Sepomex?

Looking up a Mexican postal code usually means scraping the official Correos de México site or wrangling a clunky Excel export. Sepomex turns that same official dataset into a clean, paginated JSON API you can query by zip code, state, city, municipality or colony — and, as of v1.0.0, exposes it to AI agents through the **Model Context Protocol** as well.

The whole catalog (~154k settlements) ships **inside the app as a SQLite database**, so there's nothing external to provision: clone, load, run.

## ✨ Features

- 🔎 **Search that fits the question** — query zip codes by `zip_code`, `state`, `city`, `colony`, or any combination, accent- and case-insensitive.
- 🧭 **Four resources** — zip codes (settlements), states, municipalities and cities, each with `show` and paginated `index` endpoints.
- 📄 **Predictable pagination** — every list response carries a `meta.pagination` block plus `Link` / `X-Total-*` headers.
- 🤖 **MCP server built in** — the same data as agentic tools over Streamable HTTP (`/mcp`) and stdio (`bin/mcp`).
- 🗃️ **Zero external dependencies** — bundled SQLite dataset; no Postgres, no Redis, no API keys.
- 🌐 **CORS-friendly & read-only** — safe to call straight from the browser.
- 🐳 **Dockerized** — multi-stage build, one-command dev environment, CI that ships images to Docker Hub.

> **No key, no quota, no tracking.** Sepomex is a read-only public API over public data. Run the hosted instance or host your own in minutes — the dataset travels with the code.

## 🚀 Quick start

The base URI for the hosted JSON API:

```bash
https://sepomex.icalialabs.com/api/v1
```

Grab every settlement for a postal code:

```bash
curl "https://sepomex.icalialabs.com/api/v1/zip_codes?zip_code=64000"
```

```json
{
  "zip_codes": [
    {
      "id": 1,
      "d_codigo": "64000",
      "d_asenta": "Centro",
      "d_tipo_asenta": "Colonia",
      "d_mnpio": "Monterrey",
      "d_estado": "Nuevo León",
      "d_cp": "64000",
      "...": "..."
    }
  ],
  "meta": { "pagination": { "per_page": 15, "total_pages": 1, "total_objects": 1, "links": { "first": "…", "last": "…" } } }
}
```

Prefer to run it yourself? Jump to [Development](#️-development). A health probe lives at `GET /up`.

## 🧭 Querying the API

Four resources, all under `/api/v1`:

| Resource | Endpoint | Notes |
| --- | --- | --- |
| **Zip codes** | `GET /zip_codes` | Searchable by `zip_code`, `state`, `city`, `colony` |
| **States** | `GET /states` · `GET /states/:id` | `GET /states/:id/municipalities` for its municipalities |
| **Municipalities** | `GET /municipalities` · `GET /municipalities/:id` | |
| **Cities** | `GET /cities` · `GET /cities/:id` | |

### Searching zip codes

Mix and match any of the search parameters — matching is partial and accent-insensitive:

```bash
# by postal code
curl "https://sepomex.icalialabs.com/api/v1/zip_codes?zip_code=67173"

# by city / municipality
curl "https://sepomex.icalialabs.com/api/v1/zip_codes?city=monterrey"

# by state
curl "https://sepomex.icalialabs.com/api/v1/zip_codes?state=nuevo%20leon"

# by colony (settlement)
curl "https://sepomex.icalialabs.com/api/v1/zip_codes?colony=del%20valle"

# all together
curl "https://sepomex.icalialabs.com/api/v1/zip_codes?state=nuevo%20leon&city=guadalupe&colony=del%20valle"
```

<details>
<summary>Example zip code response</summary>

```json
{
  "zip_codes": [
    {
      "id": 1,
      "d_codigo": "01000",
      "d_asenta": "San Ángel",
      "d_tipo_asenta": "Colonia",
      "d_mnpio": "Álvaro Obregón",
      "d_estado": "Ciudad de México",
      "d_ciudad": "Ciudad de México",
      "d_cp": "01001",
      "c_estado": "09",
      "c_oficina": "01001",
      "c_cp": null,
      "c_tipo_asenta": "09",
      "c_mnpio": "010",
      "id_asenta_cpcons": "0001",
      "d_zona": "Urbano",
      "c_cve_ciudad": "01"
    }
  ],
  "meta": {
    "pagination": {
      "per_page": 15,
      "total_pages": 9728,
      "total_objects": 145906,
      "links": {
        "first": "/api/v1/zip_codes?page=1",
        "last": "/api/v1/zip_codes?page=9728",
        "next": "/api/v1/zip_codes?page=2"
      }
    }
  }
}
```

</details>

### States, municipalities & cities

```bash
curl "https://sepomex.icalialabs.com/api/v1/states"
curl "https://sepomex.icalialabs.com/api/v1/states/1"
curl "https://sepomex.icalialabs.com/api/v1/states/1/municipalities"
curl "https://sepomex.icalialabs.com/api/v1/municipalities/1"
curl "https://sepomex.icalialabs.com/api/v1/cities/1"
```

<details>
<summary>Example state & municipality responses</summary>

```json
// GET /api/v1/states/1
{ "state": { "id": 1, "name": "Ciudad de México", "cities_count": 16 } }

// GET /api/v1/states/1/municipalities
{
  "municipalities": [
    { "id": 1, "name": "Álvaro Obregón", "municipality_key": "010", "zip_code": "01001", "state_id": 1 },
    { "id": 16, "name": "Xochimilco", "municipality_key": "013", "zip_code": "16001", "state_id": 1 }
  ]
}
```

</details>

### Pagination

Every `index` response is paginated — **15 per page** by default, up to **200** via `per_page` (larger values fall back to 15). Combine `per_page` with `page`:

```bash
curl "https://sepomex.icalialabs.com/api/v1/zip_codes?per_page=200&page=2"
```

Each response includes a `meta.pagination` block:

```json
"meta": {
  "pagination": {
    "per_page": 15,
    "total_pages": 9728,
    "total_objects": 145906,
    "links": {
      "first": "/api/v1/zip_codes?page=1",
      "last": "/api/v1/zip_codes?page=9728",
      "prev": "/api/v1/zip_codes?page=1",
      "next": "/api/v1/zip_codes?page=3"
    }
  }
}
```

The same numbers are also returned as `Link`, `X-Total-Pages` and `X-Total-Count` response headers.

## 🤖 MCP server

Sepomex ships a **Model Context Protocol** server so AI agents (Claude Desktop, Claude Code, Cursor, …) can query the catalog as tools. Every tool reuses the exact models and serializers behind the REST API, so both surfaces stay in sync.

| Tool | Description | Arguments |
| --- | --- | --- |
| `lookup_zip_code` | All settlements for one exact CP | `zip_code` *(required)* |
| `search_zip_codes` | Filter settlements | `zip_code`, `state`, `city`, `colony`, `limit` |
| `list_states` | The 32 states | — |
| `state_municipalities` | Municipalities of a state | `state_id` *(required)* |
| `search_cities` | Cities by name | `query`, `limit` |

Each tool returns a human-readable summary **and** `structuredContent` (the same fields as the REST serializers).

**Streamable HTTP** — mounted at `/mcp`, alongside the REST API:

```bash
curl -X POST http://localhost:3000/mcp \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"lookup_zip_code","arguments":{"zip_code":"64000"}}}'
```

**stdio** — `bin/mcp` serves the protocol over stdin/stdout against the local database. Add it to your client config:

```json
{
  "mcpServers": {
    "sepomex": { "command": "/absolute/path/to/sepomex/bin/mcp" }
  }
}
```

By default `bin/mcp` uses the development database; set `RAILS_ENV=production` to serve the bundled production catalog.

## 🛠️ Development

The dataset lives in a bundled SQLite database, so there's no external service to run. Set up locally with `rbenv`/`ruby` or with Docker.

**Local (rbenv / ruby)**

```bash
git clone git@github.com:IcaliaLabs/sepomex.git
cd sepomex
bundle install
bin/rails db:prepare        # create the SQLite database + load the schema
bin/rake data:loadev        # import the ~154k settlements from the bundled CSV
bin/rails server            # http://localhost:3000
```

**Docker**

```bash
docker compose run --rm development bash   # shell in the dev container
bin/rails db:prepare && bin/rake data:loadev
exit
docker compose up                          # http://localhost:3000
```

**Running specs**

```bash
bundle exec rspec                 # locally
docker compose run --rm tests     # in the container (as CI does)
```

### Refreshing the data

Update the bundled dataset from the latest official [SEPOMEX export](https://www.correosdemexico.gob.mx/SSLServicios/ConsultaCP/CodigoPostal_Exportar.aspx) (a `CPdescarga.xml` file):

```bash
rake "data:import_xml[/path/to/CPdescarga.xml]"   # regenerate lib/sepomex_db.csv
bin/rails db:reset && rake data:loadev            # rebuild the DB from it
```

`data:import_xml` streams the XML (so the ~67 MB file never loads fully into memory) and writes the pipe-delimited CSV the loader consumes.

## 🧱 Architecture

```
app/
├── controllers/
│   ├── api/v1/                     # REST endpoints (zip_codes, states, municipalities, cities)
│   ├── concerns/paginatable.rb     # meta.pagination + Link / X-Total-* contract
│   └── mcp_controller.rb           # MCP over Streamable HTTP  →  POST /mcp
├── mcp/sepomex_mcp/                # MCP server + the 5 tools
├── models/                         # ZipCode, State, Municipality, City, FtsZipCode
├── serializers/                    # Active Model Serializers (:json adapter)
└── services/                       # CSV loader + XML→CSV importer
bin/mcp                             # MCP over stdio
lib/sepomex_db.csv                  # bundled dataset (~154k rows)
```

**Stack:** Ruby 3.4 · Rails 8.1 (API-only) · SQLite · Puma · Active Model Serializers · [`mcp`](https://github.com/modelcontextprotocol/ruby-sdk)

## 🔁 How it ships

Pushing to `main` runs the GitHub Actions pipeline (`.github/workflows`): it builds the Docker `testing` image, runs the spec suite, then builds and pushes the `release` image to **Docker Hub** (`icalia/sepomex`). The production image bakes the SQLite catalog at build time; hosting runs on **Azure Web Apps**.

## 🗺️ Roadmap

- Automate the data refresh from the official XML export.
- Optional bearer-token gating for the MCP endpoint.
- Deeper agentic tooling (specialist agents / plugins).

## 📓 Changelog

Notable changes are recorded in [CHANGELOG.md](CHANGELOG.md).

## 🤝 Contributing

Pull requests are welcome — please branch off `main` and open one against a separate branch. This project follows the [Contributor Covenant](http://contributor-covenant.org/version/1/2/0/).

## 📄 License

Code and documentation © 2013–2026 [Icalia Labs](https://github.com/IcaliaLabs), released under the [MIT License](LICENSE).
