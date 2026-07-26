# Declarative vs Imperative - CKAD Exam Tips

## Exam Guidance

- **Declarative is preferred** for most CKAD tasks: safer, reproducible, and auditable.
- **Imperative is faster** for simple scaffolding when time is limited.

## Recommended Workflow

1. Start with dry-run imperative to generate YAML:
   ```bash
   kubectl create deployment nginx --image=nginx:1.25 --replicas=3 --dry-run=client -o yaml > nginx.yaml
   ```
2. Edit YAML locally (vim/VS Code).
3. Apply declaratively:
   ```bash
   kubectl apply -f nginx.yaml
   ```
4. Verify:
   ```bash
   kubectl get deployment nginx
   kubectl rollout status deployment/nginx
   ```

## Quick Decision Table

| Scenario | Recommended Approach |
| :--- | :--- |
| Complex object with many fields | Declarative (YAML) |
| Quick one-liner during exam | Imperative (`kubectl create/run/expose`) |
| Need to reproduce state later | Declarative (commit to Git) |
| Simple scalar updates | Imperative (`kubectl set/scale`) |
| Need to inspect before applying | Declarative with `--dry-run` |
| Objects already exist | Imperative (`kubectl edit/patch`) or declarative `apply` |

## Pitfalls

1. **Mixing declarative and imperative carelessly**: If you `kubectl apply` then `kubectl edit`, next `apply` may conflict or overwrite manual changes.
2. **Forgetting `--prune`**: declarative apply does not delete objects removed from manifest by default.
3. **Server-side apply ownership**: With multiple operators, field ownership can become complex.

## Time-Saver
```bash
alias k=kubectl

# Always start from declarative for complex tasks
k create deployment web --image=nginx --replicas=3 $do > deploy.yaml
# edit deploy.yaml
k apply -f deploy.yaml
```
