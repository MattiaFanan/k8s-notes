# NetworkPolicy: default-deny then allow specific traffic

**Task:** In namespace `secure`, deny all ingress by default, then allow ingress to pods labeled `app=api` only from pods labeled `role=frontend`, on port 8080.

**Fastest route:** no imperative create for NetworkPolicy — write minimal YAML directly (it's short).

`deny-all.yaml`:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: secure
spec:
  podSelector: {}
  policyTypes: ["Ingress"]
```

`allow-frontend.yaml`:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-api
  namespace: secure
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes: ["Ingress"]
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 8080
```
```bash
k apply -f deny-all.yaml -f allow-frontend.yaml
```

**Verify:**
```bash
k get networkpolicy -n secure
k describe networkpolicy allow-frontend-to-api -n secure
```

**Gotcha:** an empty `podSelector: {}` means "all pods in namespace." NetworkPolicies are additive — allow rules only add exceptions to a deny within their own `podSelector` scope; they don't override unrelated deny policies for pods they don't select. Also: NetworkPolicy needs a CNI that enforces it (Calico/Cilium) — some clusters silently ignore it.
