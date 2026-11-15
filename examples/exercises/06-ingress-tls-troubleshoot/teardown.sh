#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns ingress-06 --ignore-not-found
rm -f "$(dirname "$0")"/store.{crt,key}
