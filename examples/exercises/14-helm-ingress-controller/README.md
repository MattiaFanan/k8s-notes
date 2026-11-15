# 14 – Helm: install an ingress controller and make it the default class

Run `./setup.sh` first. Namespace for the app: `helm-14` (Service `echo`, port 80, answers `echo`).

traefik already uses ports 80/443 on this node, so the new controller is exposed with **NodePorts**.

1. Find chart `ingress-nginx` in repo `https://kubernetes.github.io/ingress-nginx`. List the available versions and
   look at its values (`helm show values`) to find the keys for: service type/nodePorts, IngressClass name, default class.
2. Install release `ingress-nginx`, chart version **4.15.1**, in namespace `ingress-nginx` (create it with helm), with
   values from a file `values.yaml` you write:
   - controller Service type `NodePort`, http nodePort `30080`, https nodePort `30443`
   - IngressClass resource `nginx`, marked as **default**
   Wait until it is ready.
3. Create an Ingress `echo` in `helm-14` **without** `ingressClassName`: host `echo.ckad.local`, `/` -> `echo:80`.
   Which class did it get? traefik is also marked default. Why did nginx win?
4. Test:
   ```bash
   curl -H 'Host: echo.ckad.local' http://127.0.0.1:30080/   # echo  (ingress-nginx)
   curl -H 'Host: echo.ckad.local' http://127.0.0.1/         # 404   (traefik ignores it)
   ```
5. Look at the release with `helm list -A`, `helm status`, `helm get values`, `helm get manifest`.
   Do **not** modify the traefik IngressClass.

Note: while this exercise is installed, Ingresses created without a class get `nginx` (this affects exercise 05).
`./teardown.sh` uninstalls the release.
