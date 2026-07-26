# NetworkPolicies - CKAD Exam Tips

## Shortcuts
- Start with default-deny, then add allow rules.
- Always allow egress to **port 53 UDP/TCP** to prevent DNS issues.

## Pitfalls
1. **Forgetting namespace**: NetworkPolicy applies only within its own namespace.
2. **Missing `policyTypes`**: Without `Ingress/Egress`, no traffic is affected by that policy.
3. **Combining AND/OR logic**: List items are OR; selectors within single item are AND.

## Time-Saver
```bash
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
