# 20 – Solution

```bash
kubectl apply -f limits.yaml
kubectl create quota team-quota -n quota-20 --hard=requests.cpu=500m,requests.memory=512Mi,limits.memory=1Gi,pods=4,count/deployments.apps=2   # imperative alternative
kubectl create deploy filler -n quota-20 --image=busybox:1.36 --replicas=3 -- sleep 3600
kubectl get pod -n quota-20 -l app=filler -o jsonpath='{.items[0].spec.containers[0].resources}'
kubectl run too-big -n quota-20 --image=busybox:1.36 --overrides='{"spec":{"containers":[{"name":"too-big","image":"busybox:1.36","resources":{"limits":{"memory":"300Mi"}}}]}}'
#   Error: maximum memory usage per Container is 256Mi, but limit is 300Mi
kubectl scale deploy filler -n quota-20 --replicas=6
kubectl get deploy filler -n quota-20          # 4/6
kubectl describe rs -n quota-20 | grep -A3 Events   # exceeded quota: team-quota, requested: pods=1, used: pods=4, limited: pods=4
kubectl describe quota team-quota -n quota-20
```

## Key points
- **LimitRange** = defaults and min/max **per container** (or per Pod/PVC), applied by admission when the pod is created.
  The pod spec in etcd then contains the values, which is why the pods have resources and the Deployment template does not.
  Changing a LimitRange does not change pods that already exist.
- **ResourceQuota** = a **total** for the namespace (`requests.*`, `limits.*`, object counts `pods`, `count/<resource>.<group>`).
  When a quota covers `requests.cpu`, every new pod **must** set that request (or get it from a LimitRange).
- Quota errors happen when the **pod** is created. For a Deployment you don't see an error on `kubectl scale`. The ReplicaSet
  keeps trying, and the reason is only in its events: always `kubectl describe rs` when READY < desired.
- Here `pods: 4` is the limit that stops it (CPU would allow 5 × 100m = 500m).

## Answer
Without a LimitRange, a pod without requests would be **rejected**: `failed quota: team-quota: must specify limits.memory,requests.cpu,requests.memory`.
