#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
W="$(dirname "$0")/work"; mkdir -p "$W"
ns config-31
printf 'log.level=info\ncache.size=100\n' > "$W/app.properties"
echo "namespace config-31 ready, $W/app.properties written"
