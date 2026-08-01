# NetworkPolicies - CKAD Exam Tips

> **CKAD Exam Version**: Kubernetes v1.35

## Shortcuts
- Start with default-deny, then add allow rules.
- Always allow egress to **port 53 UDP/TCP** to prevent DNS issues.
- Use `podSelector: {}` (empty selector) to match all pods in a namespace.
- Combine `namespaceSelector` + `podSelector` in the same `from` entry for logical AND.

## Pitfalls
1. **Forgetting namespace**: NetworkPolicy applies only within its own namespace.
2. **Missing `policyTypes`**: Without `Ingress/Egress`, no traffic is affected by that policy.
3. **Combining AND/OR logic**: List items are OR; selectors within single item are AND.
4. **Empty `podSelector` allows all, not blocks all**: `podSelector: {}` matches all pods. A default-deny policy needs `podSelector: {}` with `policyTypes: [Ingress]`.
5. **DNS blocked by egress policy**: If you apply a default-deny egress policy, DNS (port 53) will break immediately. Add DNS rules first.
6. **Namespace labels required for `namespaceSelector`**: Target namespaces must have labels for `namespaceSelector` to work.

## Time-Saver
```bash
alias k=kubectl

# Quick default deny for all in namespace
cat <<EOF > default-deny.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF
kubectl apply -f default-deny.yaml
```

## See also

- [NetworkPolicies YAML Structure](1-yaml-structure.md)
- [NetworkPolicies Core Concepts](2-mechanics/02-core-concepts.md)
- [NetworkPolicies CKAD Patterns](2-mechanics/01-common-ckad-patterns.md)
- [Services Overview](../../07-services/0-overview.md)
