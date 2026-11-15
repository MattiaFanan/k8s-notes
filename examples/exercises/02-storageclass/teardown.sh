#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns storage-02 --ignore-not-found
# Retain leaves Released PVs behind: delete them explicitly
for pv in $(kubectl get pv -o jsonpath='{range .items[?(@.spec.storageClassName=="local-retain")]}{.metadata.name}{"\n"}{end}'); do
  kubectl delete pv "$pv"
done
kubectl delete sc local-retain --ignore-not-found
