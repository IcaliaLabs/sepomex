
# [Sepomex](https://github.com/IcaliaLabs/sepomex)

Sepomex is a REST API that maps all the data from the current zip codes in Mexico. You can get the CSV or Excel files from the [official site](https://www.correosdemexico.gob.mx/SSLServicios/ConsultaCP/CodigoPostal_Exportar.aspx)

We build this API in order to provide a way to developers query the zip codes, states and municipalities across the country.

## Table of contents

- [Quick start](#quick-start)
- [Querying the API](#querying-the-api)
- [About pagination](#about-pagination)
- [Development](#development)
  - [Setup the project](#setup-the-project)
  - [Running the project](#running-the-project)
  - [Stop the project](#stop-the-project)
  - [Running specs](#running-specs)
- [Contributing](#contributing)
- [License](#license)

## Quick start

The base URI to start consuming the JSON response is under:

```bash
http://sepomex.icalialabs.com/api/v1/zip_codes
```

There are currently `145,481` records on the database which were extracted from the [CSV file](https://github.com/IcaliaLabs/sepomex/blob/master/lib/support/sepomex_db.csv) included in the project.

Records are paginated with **15** records per page.

### Running the project

Pending. Here will be the instructions to run the project with Docker. TBD

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

## Development

**Setup the project**

To setup the project please follow this simple steps:

1. Clone this repository into your local machine:

```bash
$ git clone git@github.com:IcaliaLabs/sepomex.git
```

2. Change directory into the project folder:

```bash
$ cd sepomex
```

3. Run the web service in bash mode to get inside the container by using the following command:

```bash
$ docker-compose run web bash
```

4. Inside the container you need to migrate the database:

```bash
$ rails db:migrate
```

5. Next you should populate the database:

```bash
$ rails db:seed
$ rake data:load
```
This operation will take some time, due to the number of records. Rake data load will load the data from the csv files into the database, like seed does. Also, it will create the indexes for the database.

6. Close the container

```bash
$ exit
```

**Running the project**

1. Fire up a terminal and run:

```bash
$ docker-compose up
```

Once you see an output like this:

```bash
web_1        | The Gemfile's dependencies are satisfied
web_1        | 2020/08/04 17:40:21 Waiting for: tcp://postgres:5432
web_1        | 2020/08/04 17:40:21 Connected to tcp://postgres:5432
web_1        | => Booting Puma
web_1        | => Rails 6.0.3.2 application starting in development
web_1        | => Run `rails server --help` for more startup options
web_1        | Puma starting in single mode...
web_1        | * Version 3.12.6 (ruby 2.7.1-p83), codename: Llamas in Pajamas
web_1        | * Min threads: 5, max threads: 5
web_1        | * Environment: development
web_1        | * Listening on tcp://0.0.0.0:3000
web_1        | Use Ctrl-C to stop
```

This means the project is up and running.

**Stop the project**

1. Use `Ctrl-C` to stop.

2. If you want to remove the containers use:

```bash
$ docker-compose down
```

**Running specs**

To run specs, you can do:

```bash
$ docker-compose run test rspec
```

## Contributing

Please submit all pull requests against a separate branch.

### Code of conduct

This project adheres to the [Contributor Covenant 1.2](http://contributor-covenant.org/version/1/2/0/). By participating, you are expected to honor this code.

## Copyright and license

Code and documentation copyright 2013-2020 Icalia Labs. Code released under [the MIT license](LICENSE).
