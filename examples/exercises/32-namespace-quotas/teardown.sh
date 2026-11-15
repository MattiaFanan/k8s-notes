#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns dev-32 storage-32 batch-32 --ignore-not-found
rm -rf "$(dirname "$0")/work"
