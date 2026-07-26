# Pods - Scheduling Affinity - CKAD Exam Tips

## Shortcuts
- Use `nodeSelector` for simple single-label node matching when possible.
- Use `preferred` rules to influence but not hard-fail scheduling.

## Pitfalls
1. **Typo in topologyKey**: Must match exact node label key name.
2. **Required vs Preferred**: Required blocks scheduling if unmatched; preferred still schedules elsewhere.
3. **IgnoredDuringExecution**: Changing labels does not evict existing Pods.

## Time-Saver
```bash
# Quick node label + pod template
kubectl label nodes node1 disktype=ssd
kubectl run pod --image=nginx $do | sed '/containers:/a\  affinity:\n    nodeAffinity:\n      requiredDuringSchedulingIgnoredDuringExecution:\n        nodeSelectorTerms:\n        - matchExpressions:\n          - key: disktype\n            operator: In\n            values: ["ssd"]'
```
