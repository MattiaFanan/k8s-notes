#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
mkdir -p "$(dirname "$0")/work/kust"
ns helm-27; ns helm-27-kust; echo "namespaces helm-27, helm-27-kust ready"
