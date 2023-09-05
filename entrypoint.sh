#!/bin/bash
set -e

bin/rails db:migrate

rm -f /app/tmp/pids/server.pid

# 引数で渡されたコマンドライン引数を実行する
exec "$@"
