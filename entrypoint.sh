#!/bin/bash
set -e

bin/rails db:migrate

rm -f /app/tmp/pids/server.pid

exec "$@"
