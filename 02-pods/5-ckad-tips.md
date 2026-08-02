# Pods - CKAD Exam Tips & Shortcuts

> **CKAD Exam Version**: Kubernetes v1.35

## Speed Shortcuts & Setup

```bash
# Set alias and short dry-run environment variable in ~/.bashrc
alias k=kubectl
export do="--dry-run=client -o yaml"

# Fast pod generation
k run busybox --image=busybox $do --command -- env > pod.yaml
```

## Vim Quick Settings (`~/.vimrc`)
```vim
set tabstop=2
set shiftwidth=2
set expandtab
```

## Key Pitfalls to Avoid on CKAD
1. **Wrong Namespace**: Always check if the question specifies a namespace (`-n <namespace>`).
2. **Missing Command Separators**: When specifying custom commands imperatively, put `--` before the command args:
   ```bash
   k run test --image=busybox $do -- sh -c "echo hello"
   ```
3. **Forgetting `--` in `kubectl exec`**: Always use `--` before the command executed inside a container:
   ```bash
   k exec -it mypod -- sh
   ```
4. **Deleting Pods slowly**: Use `--force --grace-period=0` if you need to delete a stuck pod instantly.
5. **`kubectl run` creates a Deployment, not a Pod**: In modern Kubernetes, `kubectl run` creates a Deployment by default. Use `--restart=Never` for a Pod.
6. **`kubectl run` does not create a Service**: You must create a Service separately to expose the pod.

## Time-Saver

```bash
alias k=kubectl

# Quick one-shot pod
k run debug --image=busybox --restart=Never -it -- sh

# Quick deployment with dry-run
k create deployment web --image=nginx $do > deploy.yaml

# Quick service
k expose deployment web --port=80 --target-port=8080
```

## See also

- [Pods YAML Structure](1-yaml-structure.md)
- [Pod Lifecycle & Mechanics](2-mechanics/01-core-mechanics-lifecycle.md)
- [Multi-Container Pods](2-mechanics/00-multi-container-pods/5-ckad-tips.md)
