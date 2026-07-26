# NetworkPolicies - YAML Structure

NetworkPolicies define how groups of pods are allowed to communicate with each other and with other network endpoints. They act as a firewall at the pod level, controlling ingress (incoming) and egress (outgoing) traffic based on pod labels, namespaces, IP blocks, and ports. By default, pods are not isolated—traffic is allowed unless a NetworkPolicy selects them and denies it. NetworkPolicies are implemented by the CNI plugin configured in the cluster, so not all clusters enforce them.

## Basic Allow-Egress-Only Policy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all-ingress
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-ns
    ports:
    - protocol: TCP
      port: 80
  egress:
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
```

## Specific Pod Allow Policy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-db-access
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 5432
```

## Default Deny All

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

## Field Reference

| Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage |
|---|---|---|---|
| `apiVersion` | Required | No | Must be `networking.k8s.io/v1`. Not editable after creation. |
| `kind` | Required | No | Must be `NetworkPolicy`. Not editable after creation. |
| `metadata.name` | Required | No | Immutable after creation. Must be unique within the namespace. |
| `metadata.namespace` | Optional | Yes | Defaults to `default`. NetworkPolicy is namespace-scoped; it only affects pods in its own namespace. |
| `spec.podSelector` | Required | Yes | `{}` (empty) selects **all pods** in the namespace. Use label selectors (e.g. `matchLabels`) to target specific pods. |
| `spec.policyTypes` | Optional (inferred) | Yes | Inferred from the presence of `ingress`/`egress` fields, but explicitly declaring them is safer and clearer. Valid values: `Ingress`, `Egress`. |
| `spec.ingress` | Optional | Yes | Controls inbound traffic. Each rule's `from` items are OR; fields within a single `from` item are AND. |
| `spec.egress` | Optional | Yes | Controls outbound traffic. Same AND/OR logic as `ingress`. If absent and `Egress` is in `policyTypes`, all egress is denied. |
| `spec.ingress[].from` | Optional | Yes | List of sources. `namespaceSelector` + `podSelector` in the **same** item = AND; **separate** items = OR. |
| `spec.egress[].to` | Optional | Yes | Same AND/OR semantics as `ingress[].from`. |
| `from[].namespaceSelector` | Optional | Yes | Selects pods in matching namespaces. Combined with `podSelector` in the same item as AND. |
| `from[].podSelector` | Optional | Yes | Selects pods with matching labels. Combined with `namespaceSelector` in the same item as AND. |
| `from[].ipBlock` | Optional | Yes | CIDR-based rule (e.g. `0.0.0.0/0` for all IPv4). Cannot be combined with `namespaceSelector`/`podSelector` in the same item. |
| `from[].ports` | Optional | Yes | Protocol/port filter. Omitting means all ports/protocols. |
| `to[].ipBlock` | Optional | Yes | Same as `from[].ipBlock` but for egress destinations. |
| `to[].ports` | Optional | Yes | Same as `from[].ports` but for egress rules. |

### Key Concepts

- **AND vs OR in `from`/`to`**: When `namespaceSelector` and `podSelector` appear in the **same** object within a `from` or `to` list, they are combined with **AND**. When they appear as **separate** items in the list, they are combined with **OR**.
- **Namespace scope**: A `NetworkPolicy` only affects pods in its own namespace. It cannot select pods in other namespaces directly, though `namespaceSelector` in `from`/`to` can reference other namespaces.
- **Default behavior**: Without a NetworkPolicy, all traffic (ingress and egress) is allowed. A NetworkPolicy only restricts pods it selects.
