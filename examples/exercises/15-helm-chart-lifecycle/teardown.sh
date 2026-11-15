#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
helm uninstall shop -n helm-15 2>/dev/null
kubectl delete ns helm-15 --ignore-not-found
rm -rf "$(dirname "$0")/work"
