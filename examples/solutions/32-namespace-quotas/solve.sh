#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(dirname "$0"); W="$D/../../exercises/32-namespace-quotas/work"
kubectl apply -f "$D/quotas.yaml"
# A
kubectl rollout restart deploy/web -n dev-32
kubectl rollout status deploy/web -n dev-32 --timeout=120s
kubectl scale deploy web -n dev-32 --replicas=4
echo limits.cpu > "$W/blocking.txt"
# B
pvc() { kubectl apply -f - <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: $1, namespace: storage-32}
spec: {accessModes: [ReadWriteOnce], resources: {requests: {storage: $2}}}
YAML
}
pvc data-1 300Mi; pvc tiny 50Mi; pvc data-2 300Mi
# C
for p in be-1 be-2; do kubectl run $p -n batch-32 --image=busybox:1.36 -- sleep 3600; done
kubectl run burst -n batch-32 --image=busybox:1.36 --overrides='{"spec":{"containers":[{"name":"burst","image":"busybox:1.36","command":["sleep","3600"],"resources":{"requests":{"cpu":"50m","memory":"32Mi"}}}]}}'
kubectl create cm cm-1 -n batch-32 --from-literal=a=1
kubectl create cm cm-2 -n batch-32 --from-literal=a=1
echo kube-root-ca.crt > "$W/why-cm.txt"
kubectl create svc nodeport svc-np -n batch-32 --tcp=80:80
kubectl create svc clusterip svc-a -n batch-32 --tcp=80:80
kubectl apply -f "$D/ratio.yaml"
kubectl run greedy -n batch-32 --image=busybox:1.36 --overrides='{"spec":{"containers":[{"name":"greedy","image":"busybox:1.36","resources":{"requests":{"cpu":"50m"},"limits":{"cpu":"200m"}}}]}}'
kubectl run be-3 -n batch-32 --image=busybox:1.36 -- sleep 3600 || echo "be-3 rejected too (no request/limit)"
sleep 15
true
