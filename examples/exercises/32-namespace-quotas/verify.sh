#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
W="$(dirname "$0")/work"
q()  { get resourcequota "$1" -n "$2" -o jsonpath="{.spec.hard.$3}"; }
lr() { get limitrange "$1" -n "$2" -o jsonpath="{.spec.limits[?(@.type==\"$3\")].$4}"; }
dry() { kubectl apply --dry-run=server -f - >/dev/null 2>&1; }
echo "A. dev-32"
check "LimitRange dev-defaults default cpu 200m" eq "$(lr dev-defaults dev-32 Container default.cpu)" 200m
check "quota compute unchanged"        eq "$(q compute dev-32 'requests\.cpu')/$(q compute dev-32 'limits\.cpu')" 500m/600m
check "Deployment template has no limits" eq "$(get deploy web -n dev-32 -o jsonpath='{.spec.template.spec.containers[0].resources.limits}')" ""
check "web wants 4"                    eq "$(get deploy web -n dev-32 -o jsonpath='{.spec.replicas}')" 4
check "3 web pods ready"               eq "$(get deploy web -n dev-32 -o jsonpath='{.status.readyReplicas}')" 3
check "work/blocking.txt = limits.cpu" eq "$(tr -d ' \n' < "$W/blocking.txt")" limits.cpu
echo "B. storage-32"
check "quota pvc count 2"              eq "$(q storage storage-32 persistentvolumeclaims)" 2
check "quota requests.storage 1Gi"     eq "$(q storage storage-32 'requests\.storage')" 1Gi
check "quota local-path 500Mi"         eq "$(q storage storage-32 'local-path\.storageclass\.storage\.k8s\.io/requests\.storage')" 500Mi
check "pvc-limits min 100Mi / max 400Mi" eq "$(lr pvc-limits storage-32 PersistentVolumeClaim min.storage)/$(lr pvc-limits storage-32 PersistentVolumeClaim max.storage)" 100Mi/400Mi
check "data-1 is 300Mi"                eq "$(get pvc data-1 -n storage-32 -o jsonpath='{.spec.resources.requests.storage}')" 300Mi
check "tiny / data-2 do not exist"     no get pvc tiny data-2 -n storage-32
check "data-2 is still rejected"       no dry <<'YAML'
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: data-2, namespace: storage-32}
spec: {accessModes: [ReadWriteOnce], resources: {requests: {storage: 300Mi}}}
YAML
echo "C. batch-32"
check "besteffort: scope BestEffort, pods 1" eq "$(get resourcequota besteffort -n batch-32 -o jsonpath='{.spec.scopes[*]}')/$(q besteffort batch-32 pods)" BestEffort/1
check "objects: cm 2, svc 1, nodeports 0" eq "$(q objects batch-32 configmaps)/$(q objects batch-32 services)/$(q objects batch-32 'services\.nodeports')" 2/1/0
check "be-1 exists, be-2 does not"     eq "$(get pod be-1 -n batch-32 -o name)|$(get pod be-2 -n batch-32 -o name)" "pod/be-1|"
check "burst exists (not BestEffort)"  eq "$(get pod burst -n batch-32 -o jsonpath='{.status.qosClass}')" Burstable
check "exactly one of cm-1 / cm-2"     eq "$(get cm cm-1 cm-2 -n batch-32 --no-headers | wc -l)" 1
check "work/why-cm.txt names kube-root-ca.crt" grep -q kube-root-ca.crt "$W/why-cm.txt"
check "svc-a exists, svc-np does not"  eq "$(get svc svc-a -n batch-32 -o name)|$(get svc svc-np -n batch-32 -o name)" "service/svc-a|"
check "ratio maxLimitRequestRatio cpu 2" eq "$(lr ratio batch-32 Container maxLimitRequestRatio.cpu)" 2
check "greedy (50m/200m) is rejected"  no dry <<'YAML'
apiVersion: v1
kind: Pod
metadata: {name: greedy, namespace: batch-32}
spec:
  containers:
  - {name: c, image: busybox:1.36, resources: {requests: {cpu: 50m}, limits: {cpu: 200m}}}
YAML
summary
