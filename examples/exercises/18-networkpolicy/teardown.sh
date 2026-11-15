#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns np-18 np-18-monitor np-18-other --ignore-not-found
