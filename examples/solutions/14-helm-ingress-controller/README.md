# 14 – Solution

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx     # the usual exam way
helm repo update
helm search repo ingress-nginx --versions | head                          # chart vs app versions
helm show values ingress-nginx/ingress-nginx --version 4.15.1 | less      # search: nodePorts, ingressClassResource

helm install ingress-nginx ingress-nginx/ingress-nginx --version 4.15.1 \
  -n ingress-nginx --create-namespace -f values.yaml --wait
#   same with --set: --set controller.service.type=NodePort --set controller.service.nodePorts.http=30080 ...

kubectl get ingressclass                   # traefik (default) and nginx (default)
kubectl apply -f ingress.yaml
kubectl get ing echo -n helm-14            # CLASS nginx
curl -H 'Host: echo.ckad.local' http://127.0.0.1:30080/
```
(`solve.sh` uses `--repo <url>`, which installs without adding a repo to your helm config.)

## Key points
- Chart **version** (4.15.1) and **app version** (controller 1.15.1) are different things. `--version` pins the chart.
- `-f values.yaml` and `--set a.b=c` override chart defaults. With both, `--set` wins, and later `-f` files win over earlier ones.
  `helm get values <release>` shows only what you set (`--all` shows the merged values).
- `--create-namespace` creates the namespace. `-n` is the namespace where the release is stored (Secrets `sh.helm.release.v1.*`).
- **Two default IngressClasses**: since Kubernetes 1.30 the admission plugin picks the **most recently created** default
  (earlier versions rejected the Ingress). Relying on that is fragile. In practice, keep exactly one default
  (`kubectl annotate ingressclass traefik ingressclass.kubernetes.io/is-default-class=false --overwrite`), or always set `ingressClassName`.
- Each controller handles only its own classes: traefik (`traefik.io/ingress-controller`) ignores class `nginx`, hence the 404 on port 80.
- ingress-nginx has been retired upstream (no more fixes after March 2026). It is still the controller most often used in exam tasks,
  but for real clusters prefer a maintained controller or the Gateway API.
- Remove: `helm uninstall ingress-nginx -n ingress-nginx` (it also removes the IngressClass it created).
