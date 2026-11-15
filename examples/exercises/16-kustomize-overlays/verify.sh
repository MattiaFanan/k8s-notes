#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
W="$(dirname "$0")/work"
env_of() { kubectl exec -n "$1" "deploy/$2" -- printenv "$3" 2>/dev/null; }
cmname() { get deploy "$2" -n "$1" -o jsonpath='{.spec.template.spec.containers[0].envFrom[0].configMapRef.name}'; }
echo "Build"
check "base builds"                    kubectl kustomize "$W/base"
check "dev overlay builds"             kubectl kustomize "$W/overlays/dev"
check "prod overlay builds"            kubectl kustomize "$W/overlays/prod"
check "base uses configMapGenerator"   grep -q configMapGenerator "$W/base/kustomization.yaml"
echo "dev (kust-dev)"
check "deploy dev-web 1/1 ready"       eq "$(get deploy dev-web -n kust-dev -o jsonpath='{.spec.replicas}/{.status.readyReplicas}')" 1/1
check "label env=dev on pod template"  eq "$(get deploy dev-web -n kust-dev -o jsonpath='{.spec.template.metadata.labels.env}')" dev
check "selector includes env=dev"      eq "$(get deploy dev-web -n kust-dev -o jsonpath='{.spec.selector.matchLabels.env}')" dev
check "service dev-web selects env=dev" eq "$(get svc dev-web -n kust-dev -o jsonpath='{.spec.selector.env}')" dev
check "configmap is dev-web-config-<hash>" has "$(cmname kust-dev dev-web)" -web-config-
check "APP_ENV=dev"                    eq "$(env_of kust-dev dev-web APP_ENV)" dev
check "LOG_LEVEL=debug"                eq "$(env_of kust-dev dev-web LOG_LEVEL)" debug
echo "prod (kust-prod)"
check "deploy prod-web 3/3 ready"      eq "$(get deploy prod-web -n kust-prod -o jsonpath='{.spec.replicas}/{.status.readyReplicas}')" 3/3
check "image nginx:1.27"               eq "$(get deploy prod-web -n kust-prod -o jsonpath='{.spec.template.spec.containers[0].image}')" nginx:1.27
check "label env=prod on pod template" eq "$(get deploy prod-web -n kust-prod -o jsonpath='{.spec.template.metadata.labels.env}')" prod
check "service prod-web selects env=prod" eq "$(get svc prod-web -n kust-prod -o jsonpath='{.spec.selector.env}')" prod
check "APP_ENV=prod"                   eq "$(env_of kust-prod prod-web APP_ENV)" prod
check "LOG_LEVEL=info (from base)"     eq "$(env_of kust-prod prod-web LOG_LEVEL)" info
check "configmap has key app.properties" has "$(get cm "$(cmname kust-prod prod-web)" -n kust-prod -o jsonpath='{.data.app\.properties}')" feature.x=on
check "nothing from prod in kust-dev"  no get deploy prod-web -n kust-dev
summary
