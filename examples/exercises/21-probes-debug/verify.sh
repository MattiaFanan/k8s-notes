#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
W="$(dirname "$0")/work"; N="-n probe-21"
p() { get deploy shop $N -o jsonpath="{.spec.template.spec.containers[0].$1}"; }
echo "Deployment shop"
check "readiness httpGet / :80"       eq "$(p readinessProbe.httpGet.path) $(p readinessProbe.httpGet.port)" "/ 80"
check "liveness httpGet / :80 every 10s, 3 failures" eq "$(p livenessProbe.httpGet.path) $(p livenessProbe.httpGet.port) $(p livenessProbe.periodSeconds) $(p livenessProbe.failureThreshold)" "/ 80 10 3"
check "startup httpGet / :80, 2s x 30" eq "$(p startupProbe.httpGet.path) $(p startupProbe.httpGet.port) $(p startupProbe.periodSeconds) $(p startupProbe.failureThreshold)" "/ 80 2 30"
check "2/2 ready"                     eq "$(get deploy shop $N -o jsonpath='{.status.readyReplicas}')" 2
check "no restarts in current pods"   eq "$(get pods $N -l app=shop -o json | jq '[.items[] | select(.metadata.deletionTimestamp == null) | .status.containerStatuses[0].restartCount] | add')" 0
echo "crasher"
check "work/crasher.txt has the error" grep -q "config file /etc/app/app.conf not found" "$W/crasher.txt"
echo "app (ephemeral container)"
check "ephemeral container debugger"  eq "$(get pod app $N -o jsonpath='{.spec.ephemeralContainers[0].name}')" debugger
check "debugger image busybox:1.36"   eq "$(get pod app $N -o jsonpath='{.spec.ephemeralContainers[0].image}')" busybox:1.36
check "debugger targets container app" eq "$(get pod app $N -o jsonpath='{.spec.ephemeralContainers[0].targetContainerName}')" app
check "app was not restarted"         eq "$(get pod app $N -o jsonpath='{.status.containerStatuses[0].restartCount}')" 0
summary
