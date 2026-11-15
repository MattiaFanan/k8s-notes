#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
mkdir -p "$(dirname "$0")/work"
ns helm-15 && echo "namespace helm-15 ready"
