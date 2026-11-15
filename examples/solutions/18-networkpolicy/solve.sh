#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl apply -f "$(dirname "$0")"/netpol.yaml && sleep 5
