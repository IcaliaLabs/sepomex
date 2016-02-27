# [Sepomex](https://github.com/IcaliaLabs/sepomex)

Sepomex is a REST API that maps all the data from the current zip codes in Mexico. You can get the CSV or Excel files from the [official site](http://www.sepomex.gob.mx/lservicios/servicios/CodigoPostal_Exportar.aspx)

We build this API in order to provide a way to developers query the zip codes, states and municipalities across the country.


## Table of contents
- [Quick start](#quick-start)
- [Querying the API](#querying-the-api)
- [Contributing](#contributing)
- [Heroes](#heroes)
- [License](#license)

## Quick start

The base URI to start consuming the JSON response is under:

```
https://sepomex-api.herokuapp.com/api/v1/
```

There are currently `145,481` records on the database which were extracted from the [CSV file](https://github.com/IcaliaLabs/sepomex/blob/master/lib/support/sepomex_db.csv) included in the project.

Records are paginated with **50** records per page.

### Running the project

#### Prerequisites

1. Install the `foreman` gem with:

```console
% gem install foreman
```

To run the api locally you can follow the next steps:

1. First clone the project `git clone https://github.com/IcaliaLabs/sepomex.git`
2. Run the `bin/setup` script
3. Lift the server `foreman start`

Or by hand

1. First clone the project `git clone https://github.com/IcaliaLabs/sepomex.git`
2. Under the `sepomex` directory run the `bundle install` command to download all the dependencies
3. Set up the `database.yml` to meet your requirements and create it
4. Migrate the database, `rake db:migrate`
5. We have provided a rake task to migrate the CSV data: `rake db:migrate:zip_codes`
6. Lift the server `foreman start`

## Querying the API

We currently provide 4 kind of resources: 

* **Zip Codes**: [https://sepomex-api.herokuapp.com/api/v1/zip_codes](https://sepomex-api.herokuapp.com/api/v1/zip_codes)
* **States**: [https://sepomex-api.herokuapp.com/api/v1/states](https://sepomex-api.herokuapp.com/api/v1/states)
* **Municipalities**: [https://sepomex-api.herokuapp.com/api/v1/municipalities](https://sepomex-api.herokuapp.com/api/v1/municipalities)
* **Cities**: [https://sepomex-api.herokuapp.com/api/v1/cities](https://sepomex-api.herokuapp.com/api/v1/cities)


### ZipCodes

In order to provide more flexibility to search a zip code, whether is by city, colony, state or zip code you can now send multiple parameters to make the appropiate search. You can fetch the:

#### by city

```bash
curl -X GET https://sepomex-api.herokuapp.com/api/v1/zip_codes -d city=monterrey
```

#### by state

```bash
curl -X GET https://sepomex-api.herokuapp.com/api/v1/zip_codes -d state=nuevo%20leon
```

#### by colony

```bash
curl -X GET https://sepomex-api.herokuapp.com/api/v1/zip_codes -d colony=punta%20contry
```

#### by cp

```bash
curl -X GET https://sepomex-api.herokuapp.com/api/v1/zip_codes -d zip_code=67173
```

#### all together

```bash
curl -X GET https://sepomex-api.herokuapp.com/api/v1/zip_codes \
-d colony=punta%20contry \
-d state=nuevo%20leon \
-d city=guadalupe
```

**Note: A link for the json attributes description is provided [here](http://www.sepomex.gob.mx/lservicios/servicios/imagenes/Descrip.pdf)**

### States

The `states` resources can be fetch through several means:

#### all

```bash
curl -X GET https://sepomex-api.herokuapp.com/api/v1/states
```

#### by id

```bash
curl -X GET https://sepomex-api.herokuapp.com/api/v1/states/1
```

#### states municipalities

```bash
curl -X GET https://sepomex-api.herokuapp.com/api/v1/states/1/municipalities
```

### Municipalities

#### all

```bash
curl -X GET https://sepomex-api.herokuapp.com/api/v1/municipalities
```

#### by id

```bash
curl -X GET https://sepomex-api.herokuapp.com/api/v1/municipalities/1
```

#### by zip_code

```bash
curl -X GET https://sepomex-api.herokuapp.com/api/v1/municipalities -d zip_code=67173
```

### Cities

#### all


```bash
curl -X GET https://sepomex-api.herokuapp.com/api/v1/cities
```

#### by id


```bash
curl -X GET https://sepomex-api.herokuapp.com/api/v1/cities/1
```


## Contributing

Please submit all pull requests against a separate branch.

### Code of conduct

This project adheres to the [Contributor Covenant 1.2](http://contributor-covenant.org/version/1/2/0/). By participating, you are expected to honor this code. 

## Heroes

**Abraham Kuri**

+ [http://twitter.com/kurenn](http://twitter.com/kurenn)
+ [http://github.com/kurenn](http://github.com/kurenn)
+ [http://klout.com/#/kurenn](http://klout.com/#/kurenn)


## Copyright and license

Code and documentation copyright 2013-2016 Icalia Labs. Code released under [the MIT license](LICENSE).
