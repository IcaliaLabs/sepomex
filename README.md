# [Sepomex](https://github.com/IcaliaLabs/sepomex)

Sepomex is a REST API that maps all the data from the current zip codes in Mexico. You can get the CSV or Excel files from the [official site](http://www.sepomex.gob.mx/lservicios/servicios/CodigoPostal_Exportar.aspx)

We build this API in order to provide a way to developers query the zip codes, as we had faced the problem if importing data like this in many projects.


## Table of contents
- [Quick start](#quick-start)
- [Contributing](#contributing)
- [Heroes](#heroes)
- [License](#license)

## Quick start

The URL to start consuming the JSON response is under:

```
http://sepomex-api.herokuapp.com/api/v1/zip_codes
```

There are currently `145,481` records on the database which were extracted from the [CSV file](https://github.com/IcaliaLabs/sepomex/blob/master/lib/support/sepomex_db.csv) included in the project.

Records are paginated with **50** records per page.

### Running the project

To run the api locally you can follow the next steps:

1. First clone the project `git clone https://github.com/IcaliaLabs/sepomex.git`
2. Under the `sepomex` directory run the `bundle install` command to download all the dependencies
3. Set up the `database.yml` to meet your requirements and create it
4. Migrate the database, `rake db:migrate`
5. We have provided a rake task to migrate the CSV data: `rake db:migrate:zip_codes`
6. Lift the server `foreman start` or `bundle exec rackup config.ru`
7. The path for the api is: `/api/v1/zip_codes`

## Contributing

Please submit all pull requests against a separate branch. Please follow the standard for naming the variables, mixins, etc.

In case you are wondering what to attack, we hnow have a milestone with the version to work, some fixes and refactors. Feel free to start one.

Thanks!

## Heroes

**Abraham Kuri**

+ [http://twitter.com/kurenn](http://twitter.com/kurenn)
+ [http://github.com/kurenn](http://github.com/kurenn)
+ [http://klout.com/#/kurenn](http://klout.com/#/kurenn)


## Copyright and license

Code and documentation copyright 2013-2014 Icalia Labs. Code released under [the MIT license](LICENSE).