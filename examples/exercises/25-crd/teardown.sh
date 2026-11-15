#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns crd-25 --ignore-not-found
kubectl delete crd backups.ckad.example.com --ignore-not-found
