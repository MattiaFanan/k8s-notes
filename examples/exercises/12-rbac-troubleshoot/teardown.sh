#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns rbac-12 --ignore-not-found
