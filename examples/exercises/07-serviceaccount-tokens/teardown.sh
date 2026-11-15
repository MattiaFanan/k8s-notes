#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns sa-07 --ignore-not-found
