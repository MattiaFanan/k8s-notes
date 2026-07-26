# Pods - Taints & Tolerations - CKAD Exam Tips

## Shortcuts
- `kubectl taint nodes node1 key=value:NoSchedule` one-liner for adding taints.
- Use `kubectl describe node` to inspect taints quickly.

## Pitfalls
1. **Removing taint syntax**: `key=value:NoSchedule-` must match exact taint.
2. **Overwrite required**: Re-tainning with different value needs `--overwrite`.
3. **TolerationSeconds**: Only applicable to `NoExecute`; ignored for `NoSchedule`.

## Time-Saver
```bash
# Quick toleration template snippet for pod.yaml
tolerations:
- key: "node-role.kubernetes.io/control-plane"
  operator: "Exists"
  effect: "NoSchedule"
```
