# 10 – Clusters, users and contexts (kubeconfig surgery)

Run `./setup.sh` first. It creates **new** files in `exercises/10-kubeconfig-contexts/work/`:
- `multi.kubeconfig`: clusters `k3s` (the real cluster) and `prod` (fake), several users and contexts
- `extra.kubeconfig`: a cluster `staging` with user `staging-dev` and context `staging-dev`

Work **only** on multi.kubeconfig, with `--kubeconfig work/multi.kubeconfig` or
`export KUBECONFIG=$PWD/work/multi.kubeconfig` (in that shell only). `~/.kube/k3s.yaml` must not change.
Do steps 1–3 **before** you change anything.

1. Write the names of all contexts, one per line, to `work/contexts.txt`.
2. Write the name of the current context to `work/current.txt`.
3. Write the server URL of cluster `prod` to `work/prod-server.txt`.
4. Create a context `team-a`: cluster `k3s`, user `k3s-admin`, namespace `team-a`.
5. Delete the context `old-ctx` and the user `old-user`.
6. Set the namespace of the existing context `prod-admin` to `payments` (keep its cluster and user).
7. Make `team-a` the current context. Using it, create namespace `team-a` and then a ConfigMap `hello`
   (`msg=world`) **without passing `-n`**.
8. Create `work/merged.kubeconfig`: a merge of `multi.kubeconfig` and `extra.kubeconfig`, with all certs embedded
   (no file paths), and current-context `team-a`.

Check with `./verify.sh`, clean up with `./teardown.sh`.
