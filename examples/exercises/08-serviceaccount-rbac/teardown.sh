#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns sa-08 sa-08-other --ignore-not-found
