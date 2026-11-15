#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns ingress-04 --ignore-not-found
