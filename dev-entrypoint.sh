#! /bin/bash

set -e


# 5: Check or install the app dependencies via Bundler:
bundle check || bundle

rake db:migrate

if [[ "$3" = "rackup" ]]; then set -- "$@" -P /tmp/sepomex.pid; fi

# 10: Execute the given or default command:
exec "$@"
