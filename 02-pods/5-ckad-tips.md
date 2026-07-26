# Pods - CKAD Exam Tips & Shortcuts

## Speed Shortcuts & Setup

```bash
# Set alias and short dry-run environment variable in ~/.bashrc
alias k=kubectl
export do="--dry-run=client -o yaml"

# Fast pod generation
k run busybox --image=busybox $do -- command -- env > pod.yaml
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
