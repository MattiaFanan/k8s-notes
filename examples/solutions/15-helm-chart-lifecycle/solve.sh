#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(cd "$(dirname "$0")" && pwd); cd "$D/../../exercises/15-helm-chart-lifecycle/work"
H="-n helm-15"
helm create webapp
helm install shop ./webapp $H --set replicaCount=2 --wait
cp "$D/prod-values.yaml" prod-values.yaml
helm upgrade shop ./webapp $H -f prod-values.yaml --wait
helm upgrade shop ./webapp $H --reuse-values --set image.tag=does-not-exist     # no --wait: it would hang
helm rollback shop 2 $H --wait
helm template shop ./webapp -f prod-values.yaml --set replicaCount=4 > rendered.yaml
helm package ./webapp -d .
