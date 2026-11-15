#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns multi-24 --ignore-not-found
