#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns rbac-11 --ignore-not-found
kubectl delete clusterrolebinding node-viewer --ignore-not-found
kubectl delete clusterrole node-viewer --ignore-not-found
