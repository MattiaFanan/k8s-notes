#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(dirname "$0")
kubectl apply -f $D/crd.yaml
kubectl wait --for=condition=Established crd/backups.ckad.example.com --timeout=30s
kubectl apply -f $D/resources.yaml
