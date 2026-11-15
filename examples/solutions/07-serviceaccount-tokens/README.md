# 07 – Solution

```bash
kubectl create sa builder -n sa-07          # then: kubectl edit sa builder, add automountServiceAccountToken: false
# or simply apply sa.yaml
kubectl apply -f sa.yaml -f pods.yaml
kubectl exec -n sa-07 no-token   -- ls /var/run/secrets/kubernetes.io/serviceaccount   # No such file
kubectl exec -n sa-07 with-token -- ls /var/run/secrets/kubernetes.io/serviceaccount   # ca.crt namespace token
kubectl create token builder -n sa-07 --duration=10m                                    # step 6
```
Tip: `kubectl run no-token --image=busybox:1.36 -n sa-07 --dry-run=client -o yaml -- sleep 3600` gives a pod skeleton.
Recent kubectl versions have no `--serviceaccount` flag on `run`, so add `serviceAccountName` in the YAML.

## Key points
- **automountServiceAccountToken** can be set on the SA (the default for its pods) and on the pod. **The pod wins.**
- The token mounted by default is a **projected, time-bound** token (about 1h, rotated by the kubelet) at
  `/var/run/secrets/kubernetes.io/serviceaccount/{token,ca.crt,namespace}`. Since 1.24 no Secret is created automatically.
- A **custom projected token** (`projected.sources[].serviceAccountToken`) lets you choose the `audience`
  (the `aud` claim, so a token for Vault cannot be replayed against the API server) and `expirationSeconds`.
- **Long-lived token**: create a Secret of `type: kubernetes.io/service-account-token` with the annotation
  `kubernetes.io/service-account.name`. It never expires, so avoid it unless you need it.
- `kubectl create token <sa> --duration=10m [--audience=x]` uses the TokenRequest API: a short-lived token, no object stored.
- Decode a token: `cut -d. -f2 <<<"$TOKEN" | base64 -d` (add `=` padding if needed) shows `aud`, `exp`, `sub`.

## Answer
Without `serviceAccountName` the pod uses the ServiceAccount **`default`** of its namespace. Every namespace gets one automatically.
`serviceAccountName` is immutable on a running pod: recreate the pod, or change the Deployment template.
