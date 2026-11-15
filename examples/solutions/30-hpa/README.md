# 30 – Solution

```bash
kubectl autoscale deploy api -n hpa-30 --min=2 --max=6 --cpu-percent=50   # newer kubectl: --cpu=50%
kubectl describe hpa api -n hpa-30
#   FailedGetResourceMetric ... failed to get cpu utilization: missing request for cpu in container hpa-example
kubectl set resources deploy api -n hpa-30 --requests=cpu=100m,memory=64Mi
kubectl get hpa api -n hpa-30 -o yaml > hpa.yaml     # edit: add behavior (see hpa.yaml), drop status
kubectl apply -f hpa.yaml
kubectl run load -n hpa-30 --image=busybox:1.36 -- /bin/sh -c "while true; do wget -q -O- http://api; done"
kubectl get hpa -n hpa-30 -w
kubectl top pods -n hpa-30
```

## Key points
- Utilization targets are a **percentage of the request**. No request means no utilization, so the HPA shows `<unknown>`
  and does nothing. With a ResourceQuota/LimitRange in the namespace the request can also come from the LimitRange default.
- Needs metrics-server (`metrics.k8s.io`). `kubectl top` failing means the HPA will fail too.
- `kubectl autoscale` writes an `autoscaling/v2` object. `behavior` (stabilization window, policies) is only settable in YAML.
- Formula: `desired = ceil(current * currentUtilization / target)`, clamped to min/max and to the `behavior` policies.
  Here scale-up is at most +2 pods every 15 s, so 2 → 4 → 6.
- Other target types: `averageValue` (e.g. `cpu: 200m` absolute), memory, `type: Pods`/`External` custom metrics.
- `kubectl get hpa` columns: TARGETS = current/target, REPLICAS = current replicas of the Deployment.

## Answers
- 5: the HPA owns `spec.replicas`. It sets it back within ~15 s (and never below `minReplicas`).
  Don't put `replicas:` in a Deployment manifest you re-apply when an HPA manages it, or each apply fights the HPA.
- 6: scale-down waits for the stabilization window (here 60 s, default 300 s) and uses the highest recommendation in that window,
  so a short dip in load doesn't remove pods.
