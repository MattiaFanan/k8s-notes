# 10 – Solution

```bash
cd exercises/10-kubeconfig-contexts/work
export KUBECONFIG=$PWD/multi.kubeconfig     # only in this shell; ~/.kube/k3s.yaml is untouched

kubectl config get-contexts -o name > contexts.txt                  # 1
kubectl config current-context > current.txt                        # 2
kubectl config view -o jsonpath='{.clusters[?(@.name=="prod")].cluster.server}' > prod-server.txt   # 3

kubectl config set-context team-a --cluster=k3s --user=k3s-admin --namespace=team-a   # 4
kubectl config delete-context old-ctx                                                # 5
kubectl config delete-user old-user
kubectl config set-context prod-admin --namespace=payments                           # 6: only changes that field
kubectl config use-context team-a                                                    # 7
kubectl create namespace team-a
kubectl create configmap hello --from-literal=msg=world        # goes to team-a, the context's namespace

KUBECONFIG=$PWD/multi.kubeconfig:$PWD/extra.kubeconfig kubectl config view --flatten > merged.kubeconfig   # 8
```

## Key points
- A kubeconfig has three lists: **clusters** (server + CA), **users** (credentials) and **contexts**
  (cluster + user + default namespace), plus `current-context`.
- `set-context <existing>` **merges**: it changes only the flags you pass.
  `kubectl config set-context --current --namespace=x` is the common exam command to switch namespace.
- `delete-context` does not delete the user or cluster it points to. Use `delete-user` / `delete-cluster` for those.
- File order: `--kubeconfig` flag > `$KUBECONFIG` (a `:`-separated list, merged; the **first** file wins on conflicts,
  and changes go to the file where the entry is defined) > `~/.kube/config`.
- `view` hides secrets (`DATA+OMITTED`). `--raw` shows them, `--flatten` embeds referenced files and is what you want
  when you write a merged file, `--minify` shows only what the current context uses.
- Many exam tasks start with `kubectl config use-context <name>`. Run it every time, or you work on the wrong cluster.
