#!/bin/bash
set -e

bin/rails db:migrate

rm -f /app/tmp/pids/server.pid

bin/rails server -b "0.0.0.0" -p 8080

# exec "$@"
