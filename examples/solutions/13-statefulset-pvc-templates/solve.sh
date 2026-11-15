#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(dirname "$0"); N="-n sts-13"
kubectl apply -f $D/statefulset.yaml -f $D/scratch-pod.yaml
kubectl rollout status sts/db $N --timeout=180s
kubectl delete pod db-1 $N
sleep 3; kubectl rollout status sts/db $N --timeout=120s
kubectl exec $N db-0 -- nslookup db-1.db.sts-13.svc.cluster.local
kubectl scale sts db --replicas=2 $N
kubectl rollout status sts/db $N --timeout=120s
kubectl wait $N pod/scratch --for=condition=Ready --timeout=120s
for i in $(seq 30); do kubectl get pvc data-db-2 $N >/dev/null 2>&1 || break; sleep 2; done
