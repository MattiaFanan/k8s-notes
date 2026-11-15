# 08 – Solution

Imperative (fast in the exam):
```bash
kubectl create sa pod-reader -n sa-08
kubectl create role read-pods -n sa-08 --verb=get,list,watch --resource=pods
kubectl create role read-pods -n sa-08 --verb=get --resource=pods/log --dry-run=client -o yaml   # see note
kubectl create rolebinding read-pods -n sa-08 --role=read-pods --serviceaccount=sa-08:pod-reader
kubectl create rolebinding view-other -n sa-08-other --clusterrole=view --serviceaccount=sa-08:pod-reader
```
Note: `kubectl create role` applies the same verbs to every `--resource`. When pods and pods/log need different verbs,
write the YAML (`rbac.yaml`) or use `kubectl edit role read-pods -n sa-08` to add the second rule.

Then `kubectl apply -f pod.yaml`, and test:
```bash
A=--as=system:serviceaccount:sa-08:pod-reader
kubectl auth can-i list pods -n sa-08 $A                     # yes
kubectl auth can-i get pods --subresource=log -n sa-08 $A    # yes
kubectl auth can-i delete pods -n sa-08 $A                   # no
kubectl auth can-i list services -n sa-08-other $A           # yes
kubectl auth can-i --list -n sa-08 $A                        # everything it can do
kubectl logs api-client -n sa-08                             # "kind": "PodList"
```

## Key points
- The username of a ServiceAccount is `system:serviceaccount:<ns>:<name>`. Its groups are
  `system:serviceaccounts` and `system:serviceaccounts:<ns>`.
- `--serviceaccount=<ns>:<name>` on `create rolebinding` needs the **namespace of the SA**, which can differ from the binding's namespace.
- **RoleBinding + ClusterRole** = reuse a cluster-wide role definition, but only inside one namespace. That is how
  `view-other` works, and why `pod-reader` cannot see services in `sa-08`.
- Inside a pod the API server is `https://kubernetes.default.svc`. Authenticate with the bearer token from
  `/var/run/secrets/kubernetes.io/serviceaccount/token` and trust `ca.crt` from the same directory.
- A 403 `Forbidden` in the logs means authentication worked but RBAC denied it. 401 means the token itself is bad or missing
  (for example `automountServiceAccountToken: false`).
