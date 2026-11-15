#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
ns rbac-11
kubectl create secret generic app-config  -n rbac-11 --from-literal=mode=prod --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic db-password -n rbac-11 --from-literal=pw=s3cr3t --dry-run=client -o yaml | kubectl apply -f -
