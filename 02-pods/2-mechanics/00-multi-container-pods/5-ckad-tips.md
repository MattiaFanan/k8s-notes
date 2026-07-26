# Multi-Container Pods - CKAD Exam Tips

## Exam Pitfalls
- **Init Containers require YAML editing**: CKAD often avoids pure-imperative init containers, expect to use YAML.
- **Volume sharing**: Ensure `volumeMounts` reference the same `volumes.name` across containers.

## Quick Pattern
```yaml
# Shared log sidecar
volumes:
- name: logs
  emptyDir: {}
# In each container:
volumeMounts:
- name: logs
  mountPath: /var/log/app
```

## Time-Saver
- Do not forget that init containers can be more than one — they run in order.
- Pre-create `emptyDir` volumes explicitly for sidecars sharing filesystem context.
