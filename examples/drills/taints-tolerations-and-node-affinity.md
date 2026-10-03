# Schedule pods with taints/tolerations and node affinity

**Task:** Taint node `node1` so only pods that tolerate it can land there. Then create a pod that tolerates the taint AND prefers nodes labeled `disktype=ssd`.

**Fastest route:**
```bash
k taint node node1 dedicated=gpu:NoSchedule

k run gpu-pod --image=nginx $do > pod.yaml
```
Edit `pod.yaml` spec:
```yaml
  tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "gpu"
    effect: "NoSchedule"
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: disktype
            operator: In
            values: ["ssd"]
```
```bash
k apply -f pod.yaml
```

**Verify:**
```bash
k describe node node1 | grep Taints
k get pod gpu-pod -o wide     # NODE column
```

**Gotcha:** taint effects: `NoSchedule` (blocks new pods), `PreferNoSchedule` (soft), `NoExecute` (evicts running pods too). Toleration without matching `effect` won't work — effect must match the taint exactly (or be omitted to tolerate all effects for that key).

Remove taint if needed: `k taint node node1 dedicated=gpu:NoSchedule-` (trailing `-` removes it).
