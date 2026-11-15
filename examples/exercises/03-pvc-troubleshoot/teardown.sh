#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns storage-03 --ignore-not-found
kubectl delete pv pv-db --ignore-not-found
