#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
N="-n hpa-30"
h() { get hpa api $N -o jsonpath="{$1}"; }
echo "Deployment api"
check "requests cpu 100m / memory 64Mi" eq "$(get deploy api $N -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}/{.spec.template.spec.containers[0].resources.requests.memory}')" 100m/64Mi
echo "HPA api"
check "targets Deployment api"        eq "$(h .spec.scaleTargetRef.kind)/$(h .spec.scaleTargetRef.name)" Deployment/api
check "min 2 / max 6"                 eq "$(h .spec.minReplicas)/$(h .spec.maxReplicas)" 2/6
check "cpu averageUtilization 50"     eq "$(h '.spec.metrics[?(@.resource.name=="cpu")].resource.target.averageUtilization')" 50
check "scaleDown window 60s"          eq "$(h .spec.behavior.scaleDown.stabilizationWindowSeconds)" 60
check "scaleUp policy 2 Pods / 15s"   eq "$(h '.spec.behavior.scaleUp.policies[?(@.type=="Pods")].value')/$(h '.spec.behavior.scaleUp.policies[?(@.type=="Pods")].periodSeconds')" 2/15
check "metrics are read (ScalingActive=True)" eq "$(h '.status.conditions[?(@.type=="ScalingActive")].status')" True
check "current cpu utilization known" has "$(h '.status.currentMetrics[*].resource.current.averageUtilization')" "[0-9]"
check "it scaled at least once (lastScaleTime)" has "$(h .status.lastScaleTime)" "T"
summary
