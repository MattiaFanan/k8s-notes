#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns hpa-30 --ignore-not-found
