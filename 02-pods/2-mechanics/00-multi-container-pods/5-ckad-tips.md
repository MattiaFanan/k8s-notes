# Multi-Container Pods - CKAD Exam Tips

## Exam Pitfalls
- **Init Containers require YAML editing**: CKAD often avoids pure-imperative init containers, expect to use YAML.
- **Volume sharing**: Ensure `volumeMounts` reference the same `volumes.name` across containers.
- **Native sidecar containers (v1.28+)**: Init containers with `restartPolicy: Always` run alongside regular containers for the Pod lifetime. They start after all regular init containers complete but before main containers start.

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
- Native sidecars use `restartPolicy: Always` on an init container — this is different from regular init containers that run once and exit.

## See also
- [Native Sidecar Containers](2-mechanics/06-native-sidecar-containers.md)
- [Init Containers](2-mechanics/03-init-containers.md)
- [Sidecar Pattern](2-mechanics/05-sidecar-pattern.md)
