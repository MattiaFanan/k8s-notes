# Pod Security Admission — Configuration

Pod Security Admission (PSA) is the admission controller that enforces Pod Security Standards (PSS) at the namespace or cluster level. It replaced the deprecated PodSecurityPolicy (PSP) admission controller.

## Enabling PSA

PSA is enabled by default in Kubernetes 1.25+. To configure PSA behavior, use the following kube-apiserver flags:

```bash
--pod-security-admission-defaults=enforce=baseline
--pod-security-admission-namespaces=enforce=restricted
```

## Namespace-Level Configuration

PSA is configured per namespace using labels. The three enforcement modes are `enforce`, `warn`, and `audit`.

### Enforce Mode

Rejects pods that violate the policy.

```bash
kubectl label namespace production pod-security.kubernetes.io/enforce=restricted
```

### Warn Mode

Adds warning annotations to violating pods but does not reject them.

```bash
kubectl label namespace staging pod-security.kubernetes.io/warn=baseline
```

### Audit Mode

Logs violations to the audit log but does not reject or warn.

```bash
kubectl label namespace dev pod-security.kubernetes.io/audit=restricted
```

### Combined Configuration

A namespace can have all three modes set simultaneously.

```bash
kubectl label namespace production \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/warn=baseline \
  pod-security.kubernetes.io/audit=restricted
```

## PSA and Namespace Inheritance

PSA uses a hierarchical inheritance model. A namespace without a PSS label inherits the policy from its closest ancestor that has a label.

```
cluster
└── namespace-a (enforce=baseline)
    └── namespace-b (no label) → inherits baseline
        └── namespace-c (enforce=restricted) → overrides to restricted
```

## Checking PSA Configuration

```bash
# Check namespace labels
kubectl get namespaces --show-labels | grep pod-security

# Check API server flags for PSA
ps aux | grep kube-apiserver | grep pod-security

# Verify PSA is working by attempting to create a privileged pod
kubectl run test-privileged --image=nginx --privileged -n production
# Expected: rejection if enforce=restricted or enforce=baseline

# Check audit logs for PSS violations
kubectl logs -n kube-system kube-apiserver-<node> | grep -i 'pod-security'
```

## Migration from PodSecurityPolicy

### Step 1: Identify PSPs in Use

```bash
kubectl get psp
kubectl describe psp <psp-name>
```

### Step 2: Map PSPs to PSS Policies

| PSP Behavior | PSS Equivalent |
|-------------|----------------|
| Allows privileged | `privileged` |
| Requires runAsNonRoot, no privileged | `baseline` |
| Requires runAsNonRoot, readOnlyRootFilesystem, drop ALL | `restricted` |

### Step 3: Remove PSP Resources

```bash
kubectl delete psp <psp-name>
```

### Step 4: Apply PSS Labels to Namespaces

```bash
kubectl label namespace production pod-security.kubernetes.io/enforce=restricted
```

### Step 5: Remove PSP Admission Controller

Remove `--enable-admission-plugins=PodSecurityPolicy` from the kube-apiserver configuration.

## Common Exam Commands

```bash
# Label a namespace to enforce restricted PSS
kubectl label namespace myns pod-security.kubernetes.io/enforce=restricted

# Label a namespace to warn about baseline
kubectl label namespace myns pod-security.kubernetes.io/warn=baseline

# Remove a PSS label
kubectl label namespace myns pod-security.kubernetes.io/enforce-

# Check effective PSS for a pod
kubectl describe pod mypod -n myns | grep -i "security\|pod-security"

# Test PSA enforcement
kubectl apply -f privileged-pod.yaml -n myns
```

## Best Practices

1. **Use `enforce` mode for production namespaces** to prevent insecure pods from running.
2. **Use `warn` mode for development namespaces** to alert without blocking.
3. **Use `audit` mode for compliance namespaces** to track violations without disrupting work.
4. **Label all namespaces** — unlabeled namespaces inherit from the cluster default (which is effectively `privileged`).
5. **Test PSA configuration** before enforcing in production by using `warn` or `audit` first.
6. **Document PSS policies** for each namespace so teams know the requirements.

## Troubleshooting

- **Pod rejected with PSS error**: Check the namespace's `pod-security.kubernetes.io/enforce` label. The pod violates that policy.
- **Pod not rejected despite PSS label**: PSA may not be enabled on the API server. Check kube-apiserver flags.
- **Warning annotations not appearing**: The namespace may have `warn` instead of `enforce`. Check the label value.
- **Audit logs not showing violations**: The audit log configuration may not be set up. Check the API server audit policy.
- **Namespace inherits wrong policy**: A parent namespace may have a label that overrides the intended policy. Remove or change the parent label.