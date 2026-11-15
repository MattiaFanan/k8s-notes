#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns jobs-23 --ignore-not-found
