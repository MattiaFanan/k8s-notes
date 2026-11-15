# 20 – ResourceQuota and LimitRange

Run `./setup.sh` first. Namespace: `quota-20`.

1. LimitRange `defaults` (type Container):
   - default **requests** `cpu: 100m`, `memory: 64Mi`
   - default **limits** `cpu: 200m`, `memory: 128Mi`
   - **max** `memory: 256Mi`
2. ResourceQuota `team-quota`:
   - `requests.cpu: 500m`, `requests.memory: 512Mi`, `limits.memory: 1Gi`
   - at most `4` pods and `2` Deployments
3. Deployment `filler` (`busybox:1.36`, `sleep 3600`, 3 replicas, **no resources in the spec**).
   Check the resources of its pods. Where do they come from?
4. Try a pod `too-big` with memory limit `300Mi`. What happens?
5. Scale `filler` to **6**. How many pods run? Find the reason (hint: ReplicaSet events), and look at `kubectl describe quota`.
6. Question: what would happen to a pod without resources if the namespace had the quota but **no** LimitRange?

Check with `./verify.sh` (after step 5), clean up with `./teardown.sh`.
