#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns probe-21 --ignore-not-found
rm -rf "$(dirname "$0")/work"
