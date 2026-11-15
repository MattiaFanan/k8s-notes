#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns storage-01 --ignore-not-found
kubectl delete pv pv-logs --ignore-not-found
echo "note: Retain keeps data on the node in /tmp/ckad/pv-logs"
