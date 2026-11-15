#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns psa-19 --ignore-not-found
rm -rf "$(dirname "$0")/work"
