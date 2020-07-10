
# [Sepomex](https://github.com/IcaliaLabs/sepomex)

Sepomex is a REST API that maps all the data from the current zip codes in Mexico. You can get the CSV or Excel files from the [official site](https://www.correosdemexico.gob.mx/SSLServicios/ConsultaCP/CodigoPostal_Exportar.aspx)

We build this API in order to provide a way to developers query the zip codes, states and municipalities across the country.

## Table of contents

- [Quick start](#quick-start)
- [Querying the API](#querying-the-api)
- [About pagination](#about-pagination)
- [Contributing](#contributing)
- [License](#license)

## Quick start

The base URI to start consuming the JSON response is under:

```bash
http://sepomex.icalialabs.com/zip_code
```

There are currently `145,481` records on the database which were extracted from the [CSV file](https://github.com/IcaliaLabs/sepomex/blob/master/lib/support/sepomex_db.csv) included in the project.

Records are paginated with **15** records per page.

### Running the project

Pending. Here will be the instructions to run the project with Docker. TBD

## Querying the API

We currently provide 4 kind of resources:

- **Zip Codes**: [http://sepomex.icalialabs.com/zip_code](https://sepomex.icalialabs.com/zip_code)
- **States**: [http://sepomex.icalialabs.com/state](https://sepomex.icalialabs.com/state)
- **Municipalities**: [http://sepomex.icalialabs.com/municipality](https://sepomex.icalialabs.com/municipality)
- **Cities**: [http://sepomex.icalialabs.com/city](https://sepomex.icalialabs.com/city)

### ZipCodes

In order to provide more flexibility to search a zip code, whether is by city, colony, state or zip code you can now send multiple parameters to make the appropiate search. You can fetch the:

#### all

```bash
curl -X GET https://sepomex.icalialabs.com/zip_code 
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

### States

The `states` resources can be fetch through several means:

#### all

```bash
curl -X GET https://sepomex.icalialabs.com/state
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
curl -X GET https://sepomex.icalialabs.com/state/1
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
curl -X GET https://sepomex.icalialabs.com/state/1/municipalities
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
curl -X GET https://sepomex.icalialabs.com/municipality
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
curl -X GET https://sepomex.icalialabs.com/municipality/1
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
curl -X GET https://sepomex.icalialabs.com/city
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
curl -X GET https://sepomex.icalialabs.com/city/1
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
  
## Contributing

Please submit all pull requests against a separate branch.

### Code of conduct

This project adheres to the [Contributor Covenant 1.2](http://contributor-covenant.org/version/1/2/0/). By participating, you are expected to honor this code.

## Copyright and license

Code and documentation copyright 2013-2020 Icalia Labs. Code released under [the MIT license](LICENSE).
