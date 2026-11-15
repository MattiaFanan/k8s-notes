#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl apply -f "$(dirname "$0")"/rbac.yaml
