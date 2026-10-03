# ServiceAccount with a scoped Role and RoleBinding

**Task:** Create ServiceAccount `pod-reader-sa` in namespace `dev` that can only `get`/`list`/`watch` pods in that namespace, then use it in a pod.

**Fastest route:**
```bash
k create serviceaccount pod-reader-sa -n dev
k create role pod-reader --verb=get,list,watch --resource=pods -n dev
k create rolebinding pod-reader-binding \
  --role=pod-reader --serviceaccount=dev:pod-reader-sa -n dev

k run sa-pod --image=nginx -n dev --overrides='
{"spec":{"serviceAccountName":"pod-reader-sa"}}'
```

**Verify:**
```bash
k auth can-i list pods --as=system:serviceaccount:dev:pod-reader-sa -n dev   # yes
k auth can-i delete pods --as=system:serviceaccount:dev:pod-reader-sa -n dev # no
k get pod sa-pod -n dev -o jsonpath='{.spec.serviceAccountName}'
```

**Gotcha:** `--overrides` with `kubectl run` is the fastest way to inject one field without hand-editing YAML — great for one-off attributes like `serviceAccountName`, `nodeName`, `hostNetwork`. `k auth can-i --as=` is the standard way to test RBAC without spinning up a real pod exec session.
