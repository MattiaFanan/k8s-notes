#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete csr jane --ignore-not-found
kubectl delete ns users-09 --ignore-not-found
rm -rf "$(dirname "$0")/work"
