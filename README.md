
# [Sepomex](https://github.com/IcaliaLabs/sepomex)

Sepomex is a REST API that maps all the data from the current zip codes in Mexico. You can get the CSV or Excel files from the [official site](https://www.correosdemexico.gob.mx/SSLServicios/ConsultaCP/CodigoPostal_Exportar.aspx)

We build this API in order to provide a way to developers query the zip codes, states and municipalities across the country.

It also ships a **[Model Context Protocol](#mcp-model-context-protocol) server**, so AI agents can query the same data as tools.

**Stack:** Ruby 3.4 · Rails 8.1 (API-only) · SQLite (bundled data) · Puma.

## Table of contents

- [Quick start](#quick-start)
- [Querying the API](#querying-the-api)
- [About pagination](#about-pagination)
- [MCP (Model Context Protocol)](#mcp-model-context-protocol)
- [Development](#development)
  - [Setup the project](#setup-the-project)
  - [Running the project](#running-the-project)
  - [Stop the project](#stop-the-project)
  - [Running specs](#running-specs)
- [Changelog](#changelog)
- [Contributing](#contributing)
- [License](#license)

## Quick start

The base URI to start consuming the JSON response is under:

```bash
http://sepomex.icalialabs.com/api/v1/zip_codes
```

There are currently `154,650` settlement records on the database which were extracted from the [CSV file](https://github.com/IcaliaLabs/sepomex/blob/master/lib/sepomex_db.csv) included in the project.

Records are paginated with **15** records per page.

See [Development](#development) to run the project locally or with Docker. A
liveness/readiness probe is available at `GET /up` (returns `200` when the app
boots healthy). For AI agents, the same data is available through the
[MCP server](#mcp-model-context-protocol).

## Querying the API

We currently provide 4 kind of resources:

- **Zip Codes**: [http://sepomex.icalialabs.com/zip_codes](https://sepomex.icalialabs.com/api/v1/zip_codes)
- **States**: [http://sepomex.icalialabs.com/states](https://sepomex.icalialabs.com/api/v1/states)
- **Municipalities**: [http://sepomex.icalialabs.com/municipalities](https://sepomex.icalialabs.com/api/v1/municipalities)
- **Cities**: [http://sepomex.icalialabs.com/cities](https://sepomex.icalialabs.com/api/v1/cities)

### Items per page
The 4 resources you can query are paginated with 15 items per page by default. You can change the number of items per page by adding the `per_page` parameter to the query string.

```bash
### ZipCodes

In order to provide more flexibility to search a zip code, whether is by city, colony, state or zip code you can now send multiple parameters to make the appropiate search. You can fetch the:
### ZipCodes
```bash
curl -X GET https://sepomex.icalialabs.com/api/v1/zip_codes?per_page=200
```
You can't request more than 200 items per page, if you do so, the API will return 15 items per page.

Also, you can mix the `per_page` parameter with the `page` parameter to get the desired page, even with the search parameters.

```bash
curl -X GET https://sepomex.icalialabs.com/api/v1/zip_codes?per_page=200&page=2
```

##### Response

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
    },
    ...
  ],
  "meta": {
    "pagination": {
      "per_page": 15,
      "total_pages": 9728,
      "total_objects": 145906,
      "links": {
        "first": "/zip_code?page=1",
        "last": "/zip_code?page=9728",
        "next": "/zip_code?page=2"
      }
    }
  }
}
```

#### by city

```bash
curl -X GET https://sepomex.icalialabs.com/api/v1/zip_codes?city=monterrey
```

#### by state

```bash
curl -X GET https://sepomex.icalialabs.com/api/v1/zip_codes?state=nuevo%20leon
```

#### by colony

```bash
curl -X GET https://sepomex.icalialabs.com/api/v1/zip_codes?colony=punta%20contry
```

#### by cp

```bash
curl -X GET https://sepomex.icalialabs.com/api/v1/zip_codes?zip_code=67173
```

#### all together

```bash
curl -X GET https://sepomex.icalialabs.com/api/v1/zip_codes?colony=punta%20contry&state=nuevo%20leon&city=guadalupe
```

### States

The `states` resources can be fetch through several means:

#### all

```bash
curl -X GET https://sepomex.icalialabs.com/api/v1/states
```

##### Response

```json
{

  "states": [
    {
      "id": 1,
      "name": "Ciudad de México",
      "cities_count": 16
    },
    ...
  ],
  "meta": {
    "pagination": {
      "per_page": 15,
      "total_pages": 3,
      "total_objects": 32,
      "links": {
        "first": "/state?page=1",
        "last": "/state?page=3",
        "next": "/state?page=2"
      }
    }
  }
}
```

#### by id

```bash
curl -X GET https://sepomex.icalialabs.com/api/v1/states/1
```

##### Response

```json
{
  "state": {
    "id": 1,
    "name": "Ciudad de México",
    "cities_count": 16
  }
}
```

#### states municipalities

```bash
curl -X GET https://sepomex.icalialabs.com/api/v1/states/1/municipalities
```

##### Response

```json
{
  "municipalities": [
    {
      "id": 1,
      "name": "Álvaro Obregón",
      "municipality_key": "010",
      "zip_code": "01001",
      "state_id": 1
    },
    ...
    {
      "id": 16,
      "name": "Xochimilco",
      "municipality_key": "013",
      "zip_code": "16001",
      "state_id": 1
    }
  ]
}
```

### Municipalities

#### all

```bash
curl -X GET https://sepomex.icalialabs.com/api/v1/municipalities
```

##### Response

```json
{
  "municipalities": [
    {
      "id": 1,
      "name": "Álvaro Obregón",
      "municipality_key": "010",
      "zip_code": "01001",
      "state_id": 1
    },
    ...
  ],
  "meta": {
    "pagination": {
      "per_page": 15,
      "total_pages": 155,
      "total_objects": 2318,
      "links": {
        "first": "/municipality?page=1",
        "last": "/municipality?page=155",
        "next": "/municipality?page=2"
      }
    }
  }
}
```

#### by id

```bash
curl -X GET https://sepomex.icalialabs.com/api/v1/municipalities/1
```

##### Response

```json
{
  "municipality": {
    "id": 1,
    "name": "Álvaro Obregón",
    "municipality_key": "010",
    "zip_code": "01001",
    "state_id": 1
  }
}
```

### Cities

#### all

```bash
curl -X GET https://sepomex.icalialabs.com/api/v1/cities
```

##### Response

```json
{
  "cities": [
    {
      "id": 1,
      "name": "Ciudad de México",
      "state_id": 1
    },
  ...
  ],
  "meta": {
    "pagination": {
      "per_page": 15,
      "total_pages": 45,
      "total_objects": 669,
      "links": {
        "first": "/city?page=1",
        "last": "/city?page=45",
        "next": "/city?page=2"
      }
    }
  }
}
```

#### by id

```bash
curl -X GET https://sepomex.icalialabs.com/api/v1/cities/1
```

##### Response

```json
{
  "city": {
    "id": 1,
    "name": "Ciudad de México",
    "state_id": 1
  }
}
```

## About pagination

The structure of a paged response is:

```json
"meta": {
    "pagination": {
      "per_page": 15,
      "total_pages": 9728,
      "total_objects": 145906,
      "links": {
        "first": "/zip_code?page=1",
        "last": "/zip_code?page=9728",
        "prev": "/zip_code?page=1",
        "next": "/zip_code?page=3"
      }
    }
  }
```

**Where:**

- ``per_page`` is the amount of elements per page.
- ``total_pages`` is the total number of pages.
- ``total_objects`` is the total objects of all pages.
- ``links`` contains links for pages.
  - ``first``is the url for the first page.
  - ``last`` is the url for the last page.
  - ``prev`` is the url for the previous page.
  - ``next`` is the url for the next page.

## MCP (Model Context Protocol)

Beyond the REST API, Sepomex ships a **Model Context Protocol** server so AI
agents (Claude Desktop, Claude Code, Cursor, …) can query Mexican postal codes
as tools. Both transports below serve the same tools and reuse the same models
as the REST API.

### Tools

| Tool | Description | Arguments |
| --- | --- | --- |
| `lookup_zip_code` | All settlements (colonias) for one exact CP | `zip_code` (required) |
| `search_zip_codes` | Filter settlements | `zip_code`, `state`, `city`, `colony`, `limit` |
| `list_states` | The 32 states | — |
| `state_municipalities` | Municipalities of a state | `state_id` (required) |
| `search_cities` | Cities by name | `query`, `limit` |

Each tool returns a human-readable summary plus `structuredContent` (the same
fields as the REST serializers).

### HTTP (Streamable HTTP)

The server is mounted at `/mcp` (stateless), alongside the REST API, so any
Streamable-HTTP MCP client can point at `https://<your-host>/mcp`:

```bash
curl -X POST http://localhost:3000/mcp \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"lookup_zip_code","arguments":{"zip_code":"64000"}}}'
```

### stdio (local)

`bin/mcp` serves the protocol over stdin/stdout against the local database. Add
it to your MCP client config (e.g. Claude Desktop's `claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "sepomex": {
      "command": "/absolute/path/to/sepomex/bin/mcp"
    }
  }
}
```

By default it uses the development database; set `RAILS_ENV=production` to serve
the bundled production catalog instead.

## Development

The data lives in a bundled SQLite database, so there is no external database
service to run. You can set the project up locally with `rbenv`/`ruby` or with
Docker.

**Local setup (rbenv / ruby)**

```bash
$ git clone git@github.com:IcaliaLabs/sepomex.git
$ cd sepomex
$ bundle install
$ bin/rails db:prepare        # create the SQLite database + load the schema
$ bin/rake data:loadev        # import the ~154k settlements from the bundled CSV
$ bin/rails server            # http://localhost:3000
```

`rake data:loadev` loads the settlements, states, municipalities and cities from
`lib/sepomex_db.csv` and builds the search indexes; it only runs when the
database is empty.

**Docker setup**

```bash
$ git clone git@github.com:IcaliaLabs/sepomex.git
$ cd sepomex
# Open a shell in the development container:
$ docker compose run --rm development bash
# Inside the container, prepare and seed the database:
$ bin/rails db:prepare
$ bin/rake data:loadev
$ exit
```

**Running the project (Docker)**

```bash
$ docker compose up
```

The container entrypoint prepares the database automatically, and Puma listens
on `http://localhost:3000`.

**Stop the project**

1. Use `Ctrl-C` to stop.

2. If you want to remove the containers use:

```bash
$ docker compose down
```

**Running specs**

Locally:

```bash
$ bundle exec rspec
```

Or, in the tests container (as CI does):

```bash
$ docker compose run --rm tests
```

## Changelog

Notable changes are recorded in [CHANGELOG.md](CHANGELOG.md).

## Contributing

Please submit all pull requests against a separate branch.

### Code of conduct

This project adheres to the [Contributor Covenant 1.2](http://contributor-covenant.org/version/1/2/0/). By participating, you are expected to honor this code.

## Copyright and license

Code and documentation copyright 2013-2026 Icalia Labs. Code released under [the MIT license](LICENSE).
