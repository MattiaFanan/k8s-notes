# 18 – Solution

```bash
kubectl apply -f netpol.yaml
kubectl get netpol -n np-18
kubectl describe netpol api-ingress -n np-18
kubectl exec -n np-18 frontend -- wget -qO- -T 3 http://api      # api
kubectl exec -n np-18 frontend -- wget -qO- -T 3 http://db       # timeout
```

## Key points
- Policies are **allow lists** and they **add up**. Once any policy selects a pod for a direction (Ingress/Egress),
  everything in that direction not allowed by some policy is dropped. No policy at all means everything is allowed.
- `default-deny` with `policyTypes: [Ingress, Egress]` and no rules is the usual starting point. After it, nothing works,
  **including DNS**. That is why `allow-dns` exists: without it `wget http://web` fails on the name lookup.
- **Both sides must allow it**: frontend -> web needs frontend's egress *and* web's ingress (the default deny blocks both).
  The return traffic of an allowed connection is allowed automatically.
- **Ports** are matched after the Service translated `80` to the pod's `5678`, so write the container port
  (or its name). Using 80 here would block everything.
- **AND vs OR** in `from`/`to`:
  ```yaml
  - namespaceSelector: {...}     # ONE item, both selectors -> pod must match both (AND)
    podSelector: {...}
  ---
  - namespaceSelector: {...}     # TWO items -> either one (OR): any pod in team=monitoring namespaces,
  - podSelector: {...}           #   OR app=prober pods in THIS namespace
  ```
  The second form would also let `intruder` in, if it were labelled `app=prober`. And it would let every pod in `np-18-monitor` in.
- `podSelector` alone only matches pods in the policy's own namespace. Every namespace has the automatic label
  `kubernetes.io/metadata.name=<name>`, which you can use to select it by name.
- Policies have no "deny" rule and no logging. Test with `wget -T`/`nc -zv -w 2` from pods with the right labels.
