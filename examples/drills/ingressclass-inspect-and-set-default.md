# IngressClass: find available classes, set a default, use one explicitly

**Task:** Cluster has multiple IngressClasses (e.g. `nginx`, `traefik`). Find which exists, which is default, and create an Ingress that explicitly uses one — or omits it to rely on the default.

**Fastest route — discover:**
```bash
k get ingressclass
k get ingressclass -o yaml | grep -A2 -i annotations   # look for is-default-class
```
An IngressClass marked default has this annotation:
```yaml
metadata:
  annotations:
    ingressclass.kubernetes.io/is-default-class: "true"
```

**Set a class as default (patch the annotation):**
```bash
k annotate ingressclass nginx ingressclass.kubernetes.io/is-default-class=true --overwrite
```
If another class already holds the annotation, remove it there first (only one default is valid):
```bash
k annotate ingressclass traefik ingressclass.kubernetes.io/is-default-class- 
```

**Create an Ingress explicitly pinned to a class:**
```bash
k create ingress my-ing --class=nginx --rule="app.example.com/*=app-svc:80"
```

**Verify:**
```bash
k get ingress my-ing -o jsonpath='{.spec.ingressClassName}'
k describe ingressclass nginx
```

**Gotcha:** an Ingress with no `ingressClassName` set and no `kubernetes.io/ingress.class` annotation only picks up a controller if exactly one IngressClass is marked default — with zero or multiple defaults, it sits unaddressed by any controller and just never gets an address. Always check `k get ingress <name> -o yaml` for an empty/missing class if traffic isn't routing.
