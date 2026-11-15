#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
ns np-18; ns np-18-monitor; ns np-18-other
kubectl label ns np-18-monitor team=monitoring --overwrite >/dev/null
for a in web api db; do echo_app np-18 $a 80; done
kubectl run frontend -n np-18 --image=busybox:1.36 -l role=frontend -- sleep 36000 2>/dev/null
kubectl run intruder -n np-18 --image=busybox:1.36 -l role=other -- sleep 36000 2>/dev/null
kubectl run prober -n np-18-monitor --image=busybox:1.36 -l app=prober -- sleep 36000 2>/dev/null
kubectl run prober -n np-18-other --image=busybox:1.36 -l app=prober -- sleep 36000 2>/dev/null
kubectl wait -n np-18 --for=condition=Available deploy --all --timeout=120s
kubectl wait -n np-18 --for=condition=Ready pod --all --timeout=120s
kubectl wait -n np-18-monitor --for=condition=Ready pod/prober --timeout=60s
kubectl wait -n np-18-other --for=condition=Ready pod/prober --timeout=60s
