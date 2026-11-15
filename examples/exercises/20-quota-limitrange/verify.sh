#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
N="-n quota-20"
lr() { get limitrange defaults $N -o jsonpath="{.spec.limits[?(@.type==\"Container\")].$1}"; }
q()  { get resourcequota team-quota $N -o jsonpath="{.spec.hard.$1}"; }
echo "LimitRange defaults"
check "defaultRequest 100m/64Mi"      eq "$(lr defaultRequest.cpu)/$(lr defaultRequest.memory)" 100m/64Mi
check "default limit 200m/128Mi"      eq "$(lr default.cpu)/$(lr default.memory)" 200m/128Mi
check "max memory 256Mi"              eq "$(lr max.memory)" 256Mi
echo "ResourceQuota team-quota"
check "requests.cpu 500m"             eq "$(q 'requests\.cpu')" 500m
check "requests.memory 512Mi"         eq "$(q 'requests\.memory')" 512Mi
check "limits.memory 1Gi"             eq "$(q 'limits\.memory')" 1Gi
check "pods 4"                        eq "$(q pods)" 4
check "count/deployments.apps 2"      eq "$(q 'count/deployments\.apps')" 2
echo "Deployment filler"
check "spec.replicas 6"               eq "$(get deploy filler $N -o jsonpath='{.spec.replicas}')" 6
check "template has no resources"     eq "$(get deploy filler $N -o jsonpath='{.spec.template.spec.containers[0].resources}')" "{}"
check "only 4 pods exist (quota)"     eq "$(get pods $N -l app=filler --no-headers | wc -l)" 4
P=$(get pods $N -l app=filler -o jsonpath='{.items[0].metadata.name}')
check "pod got request cpu 100m (LimitRange)" eq "$(get pod "$P" $N -o jsonpath='{.spec.containers[0].resources.requests.cpu}')" 100m
check "pod got limit memory 128Mi"    eq "$(get pod "$P" $N -o jsonpath='{.spec.containers[0].resources.limits.memory}')" 128Mi
check "quota used pods = 4"           eq "$(get resourcequota team-quota $N -o jsonpath='{.status.used.pods}')" 4
check "300Mi limit is rejected"       no kubectl run too-big $N --image=busybox:1.36 --dry-run=server --overrides='{"spec":{"containers":[{"name":"too-big","image":"busybox:1.36","resources":{"limits":{"memory":"300Mi"}}}]}}'
summary
