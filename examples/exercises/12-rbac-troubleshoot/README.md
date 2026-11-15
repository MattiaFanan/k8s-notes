# 12 – Troubleshoot RBAC for a CI bot

Run `./setup.sh` first. Namespace: `rbac-12`.

The CI system runs as ServiceAccount `ci-bot` in `rbac-12`. Someone created a Role `ci-deployer` and a RoleBinding
`ci-deployer` for it, and a Pod `ci-runner`, but the pipeline fails with `Forbidden`.

Make it work so that `ci-bot`, **in `rbac-12` only**, can:
- `get`, `list`, `watch`, `create`, `update`, `patch` deployments
- scale deployments (`get`, `update`, `patch` on the `scale` subresource): `kubectl scale deploy app --replicas=2` must work
- `get`, `list` pods and `get` pod logs

and **cannot**:
- delete deployments
- read secrets
- do anything in other namespaces

Also, the pod `ci-runner` must run as `ci-bot` (keep its name, image and command).

Keep the names `ci-deployer` (Role and RoleBinding). Find the bugs with `kubectl describe` and `kubectl auth can-i`.

Check with `./verify.sh`, clean up with `./teardown.sh`.
