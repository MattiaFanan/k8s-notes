#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(dirname "$0"); W="$D/../../exercises/21-probes-debug/work"; N="-n probe-21"
kubectl patch deploy shop $N --patch-file $D/probes-patch.yaml
kubectl rollout status deploy/shop $N --timeout=120s
# the crashed instance is "previous" once the container runs again; while it waits in back-off, plain logs show it
until { kubectl logs crasher $N --previous 2>/dev/null; kubectl logs crasher $N 2>/dev/null; } | grep -m1 FATAL > "$W/crasher.txt"; do sleep 2; done
kubectl debug -n probe-21 app --image=busybox:1.36 --container=debugger --target=app -- sleep 3600
