#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns sts-13 --ignore-not-found     # PVCs go with the namespace; local-path then deletes the PVs
