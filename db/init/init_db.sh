#!/bin/bash

# this script is runned when the docker container is built
# it imports the base database structure and create the database for the tests

DATABASE_NAME="sepomex_development"

# create default database
if psql -lqt | cut -d \| -f 1 | grep -qw sepomex_development; then
  echo "DATABASE ALREADY EXISTS"
else
echo "*** CREATING DATABASE ***"
gosu postgres postgres --single <<EOSQL
  CREATE DATABASE "$DATABASE_NAME";
EOSQL
echo "*** DATABASE CREATED! ***"
fi
