#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns deploy-22 --ignore-not-found
