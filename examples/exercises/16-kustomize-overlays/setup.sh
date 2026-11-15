#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
mkdir -p "$(dirname "$0")/work"
ns kust-dev; ns kust-prod; echo "namespaces kust-dev, kust-prod ready"
