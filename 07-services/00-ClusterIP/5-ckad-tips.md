# Services - ClusterIP - CKAD Exam Tips

> **CKAD Exam Version**: Kubernetes v1.35

## Exam Shortcuts
- `kubectl expose deployment <name> --port=80 --target-port=8080` is fastest scaffolding.
- Verify ready endpoints with `kubectl get endpoints <svc-name>`.
- Use `kubectl get endpointslices -l kubernetes.io/service-name=<svc>` for modern endpoint inspection.
- DNS test: `kubectl run tester --image=busybox --restart=Never --rm -it -- nslookup web-service`

## Pitfalls
1. **Forgotten namespace**: Service and Pods must be in same namespace (or use fully qualified DNS).
2. **Selector/label mismatch**: Most common cause of empty endpoints.
3. **TargetPort vs Port**: `port` is Service port; `targetPort` is Pod container port.
4. **Headless Service**: `clusterIP: None` bypasses kube-proxy and returns all Pod IPs directly to the client. Use only for StatefulSets or custom load balancing logic.
5. **EndpointSlices vs Endpoints**: Modern clusters use EndpointSlices. If `kubectl get endpoints` shows nothing, check `kubectl get endpointslices`.
6. **Session Affinity**: `ClientIP` affinity is not sticky across Pod restarts. If the backend Pod dies, the next request will hit a new Pod.
7. **Hairpin NAT**: If a Pod cannot reach its own Service IP, the CNI plugin may not support hairpin NAT. Check CNI configuration.

## Time-Saver
```bash
alias k=kubectl

# Quick debug from inside cluster
k run tester --image=busybox --restart=Never --rm -it -- nslookup web-service

# Quick service exposure
k expose deployment web --port=80 --target-port=8080

# Quick endpoint check
k get endpoints web-service
k get endpointslices -l kubernetes.io/service-name=web-service

# Quick port-forward for debugging
k port-forward svc/web-service 8080:80
```

## See also
- [Services Overview](../../07-services/0-overview.md)
- [ClusterIP YAML Structure](1-yaml-structure.md)
- [ClusterIP Core Mechanics](2-mechanics/02-core-mechanics.md)
- [ClusterIP Traffic Flow](2-mechanics/05-traffic-flow.md)
