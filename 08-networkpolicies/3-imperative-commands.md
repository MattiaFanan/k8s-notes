# NetworkPolicies - Imperative Commands

## Create NetworkPolicies

```bash
# Generate NetworkPolicy YAML with dry-run
kubectl create networkpolicy my-policy \
  --pod-selector app=database \
  --ingress \
  --from-pod-selector app=backend \
  --port 5432 \
  --dry-run=client -o yaml > netpol.yaml

# Apply explicit policy
kubectl apply -f netpol.yaml
```

## Default-Deny Ingress

```bash
# Deny all ingress to pods in a namespace
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: myns
spec:
  podSelector: {}
  policyTypes:
  - Ingress
EOF
```

## Default-Deny Egress

```bash
# Deny all egress from pods in a namespace
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-egress
  namespace: myns
spec:
  podSelector: {}
  policyTypes:
  - Egress
EOF
```

## Allow Ingress from a Specific Namespace

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-frontend
  namespace: myns
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
EOF
```

## Allow Ingress from a Specific Pod Label

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-web
  namespace: myns
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: web
EOF
```

## Allow Egress to a Specific CIDR

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-egress-to-cidr
  namespace: myns
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 10.0.0.0/16
        except:
        - 10.0.1.0/24
    ports:
    - protocol: TCP
      port: 443
EOF
```

## Allow DNS Egress (Critical for Default-Deny)

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: myns
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
EOF
```

## Verify Policy

```bash
# List policies in namespace
kubectl get networkpolicy -n <namespace>

# Describe policy details
kubectl describe networkpolicy <policy-name>

# Check effective permissions for a pod
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.metadata.labels}'
```

## Delete

```bash
kubectl delete networkpolicy <policy-name>
```