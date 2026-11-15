# 05 – Solution

```bash
kubectl get ingressclass                 # traefik (default), controller traefik.io/ingress-controller
kubectl get ingressclass traefik -o yaml # annotation ingressclass.kubernetes.io/is-default-class: "true"
kubectl apply -f ingressclass.yaml -f ingresses.yaml
kubectl get ing -n ingress-05            # CLASS column
```

## Key points
- **IngressClass** is cluster-scoped. `spec.controller` says *which controller* handles Ingresses of that class.
  Traefik serves every IngressClass whose controller is `traefik.io/ingress-controller`, so `traefik-internal` works.
  In real setups you use this to split traffic between two controllers (internal and public, nginx and traefik).
- `spec.parameters` (optional) points to controller-specific configuration.
- **Default class**: the annotation `ingressclass.kubernetes.io/is-default-class: "true"`. When an Ingress is
  **created** without a class, the `DefaultIngressClass` admission plugin writes the default class name into
  `spec.ingressClassName`. That is why `hello-default` shows `traefik`. Ingresses that already exist are not updated.
- **legacy**: it used the deprecated annotation `kubernetes.io/ingress.class: nginx`, so it asked for an nginx controller
  that does not exist (and because the annotation was set, admission did not fill in the default).
  Fix: remove the annotation and set the field:
  ```bash
  kubectl annotate ing legacy -n ingress-05 kubernetes.io/ingress.class-
  kubectl patch ing legacy -n ingress-05 --type merge -p '{"spec":{"ingressClassName":"traefik"}}'
  ```
  (or `kubectl edit ing legacy -n ingress-05`, or `kubectl apply -f legacy.yaml`: setup also used `apply`,
  so apply removes the annotation that is gone from the file).
