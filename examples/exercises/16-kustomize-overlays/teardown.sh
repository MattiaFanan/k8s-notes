#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns kust-dev kust-prod --ignore-not-found
rm -rf "$(dirname "$0")/work"
