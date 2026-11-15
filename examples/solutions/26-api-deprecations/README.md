# 26 – Solution

The fixed manifests are in `new/`.

```bash
kubectl apply -f work/old/
#   no matches for kind "Deployment" in version "extensions/v1beta1"  (same for the others)
kubectl api-resources | grep -E 'deployments|ingresses|cronjobs|poddisruptionbudgets|horizontalpodautoscalers'
kubectl explain ingress | head -3          # GROUP: networking.k8s.io  VERSION: v1
kubectl api-versions | grep autoscaling    # autoscaling/v1, autoscaling/v2
kubectl explain hpa.spec.metrics.resource.target --api-version=autoscaling/v2
kubectl apply -f work/new/
```

## What changed
| kind | old | new | field changes |
|------|-----|-----|---------------|
| Deployment | extensions/v1beta1 | apps/v1 | `spec.selector` now **required** and must match the template labels |
| Ingress | extensions/v1beta1 | networking.k8s.io/v1 | `backend.serviceName/servicePort` became `backend.service.name/port.number`, `pathType` required, class goes in `spec.ingressClassName` |
| CronJob | batch/v1beta1 | batch/v1 | none |
| PodDisruptionBudget | policy/v1beta1 | policy/v1 | none (an empty selector now selects all pods) |
| HPA | autoscaling/v2beta1 | autoscaling/v2 | `targetAverageUtilization: 50` became `target: {type: Utilization, averageUtilization: 50}` |

## Key points
- `kubectl api-resources` shows the **preferred** version of each kind, and `kubectl api-versions` all served group/versions.
  `kubectl explain <kind>.<field> --api-version=<g/v>` shows the schema of one version.
- The `kubectl convert` plugin (separate download, not installed here) can rewrite manifests for you:
  `kubectl convert -f old.yaml --output-version apps/v1`. In the exam, `kubectl explain` and the docs are usually faster.
- The Kubernetes "Deprecated API Migration Guide" lists every removal with the field changes.
- A deprecated (but still served) version gives a **warning** on apply, so read the warnings.
