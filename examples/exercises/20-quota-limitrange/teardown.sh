#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns quota-20 --ignore-not-found
