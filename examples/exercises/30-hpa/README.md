# 30 – HorizontalPodAutoscaler

Run `./setup.sh` first. Namespace: `hpa-30`. metrics-server is already running in k3s (`kubectl top pods -A` works).

Setup creates Deployment `api` (`registry.k8s.io/hpa-example`, 2 replicas, **no resources**) and Service `api:80`.

1. Create an HPA quickly with `kubectl autoscale`: target `api`, min `2`, max `6`, CPU `50%`.
   Run `kubectl get hpa -n hpa-30` for a minute. Why is TARGETS `<unknown>/50%`? (hint: `kubectl describe hpa`)
2. Fix it **on the Deployment**: requests `cpu: 100m`, `memory: 64Mi`.
3. Turn the HPA into an `autoscaling/v2` manifest (`kubectl get hpa api -o yaml`, then edit) that also has:
   - `behavior.scaleDown.stabilizationWindowSeconds: 60`
   - `behavior.scaleUp.policies`: at most `2` Pods every `15` seconds
4. Make load:
   `kubectl run load -n hpa-30 --image=busybox:1.36 -- /bin/sh -c "while true; do wget -q -O- http://api; done"`
   Watch `kubectl get hpa -n hpa-30 -w` and `kubectl get deploy api -n hpa-30 -w`. How fast does it go up?
5. While the HPA is active, run `kubectl scale deploy api -n hpa-30 --replicas=1`. What happens?
6. Delete the `load` pod. How long until it scales down, and why that long?

Check with `./verify.sh` (after step 4, while `load` runs), clean up with `./teardown.sh`.
