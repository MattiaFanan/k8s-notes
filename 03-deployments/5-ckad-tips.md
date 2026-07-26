# Deployments & Workloads - CKAD Exam Tips

## Exam Speed Shortcuts

- Always use `kubectl set image` for quick updates during exam questions instead of manually editing YAML.
- Use `kubectl create deployment web --image=nginx $do > deploy.yaml` to quickly scaffold deployments.
- Remember `kubectl rollout undo` for instant rollback when an update breaks.

## Key Checklist & Pitfalls
- **Job Restart Policy**: Pods managed by Jobs MUST set `restartPolicy: OnFailure` or `Never`. `Always` will fail validation!
- **Match Labels**: Deployments created with `kubectl create deployment` automatically set `app=<name>` matchLabels. If modifying manually, do not break label alignment.
