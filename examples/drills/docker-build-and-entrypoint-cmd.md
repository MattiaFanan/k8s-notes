# Docker: build/tag/push an image, and map ENTRYPOINT/CMD to pod command/args

**Task:** Build an image from a `Dockerfile`, tag it, push it, then run it as a pod overriding its default command — the recurring CKAD trick is knowing how `ENTRYPOINT`/`CMD` in the image map to `command`/`args` in the pod spec.

**Fastest route — build/tag/push:**
```bash
docker build -t myrepo/app:1.0 .
docker run --rm myrepo/app:1.0            # sanity check locally before pushing
docker push myrepo/app:1.0
```

**Inspect what a running container will actually execute:**
```bash
docker inspect myrepo/app:1.0 --format='{{.Config.Entrypoint}} {{.Config.Cmd}}'
# or:
docker history myrepo/app:1.0 --no-trunc | grep -i -E 'entrypoint|cmd'
```

**The mapping that CKAD tests directly:**
| Dockerfile | Pod spec field | Effect |
|---|---|---|
| `ENTRYPOINT` | `command` | overrides ENTRYPOINT entirely if set |
| `CMD` | `args` | overrides CMD entirely if set |

- Pod `command` set, `args` unset → runs `command` with the image's `CMD` args dropped.
- Pod `command` unset, `args` set → runs image's `ENTRYPOINT` with these `args` instead of image's `CMD`.
- Both unset → runs image's `ENTRYPOINT` + `CMD` as-is.

**Fastest route — override at pod level without touching the Dockerfile:**
```bash
k run app --image=myrepo/app:1.0 --command -- /bin/sh -c 'echo hi; sleep 3600'
```
(`--command` here tells `kubectl run` that everything after `--` is the container's `command`, not `args`.)

Or generate + edit for both fields explicitly:
```bash
k run app --image=myrepo/app:1.0 $do > pod.yaml
```
```yaml
    command: ["/bin/sh", "-c"]
    args: ["echo hi && sleep 3600"]
```

**Verify:**
```bash
k logs app
k exec app -- ps aux    # confirm the actual running process/args
```

**Gotcha:** the exam commonly gives you a Dockerfile and asks "fix the container so it does X" — check whether the fix belongs in the Dockerfile (`ENTRYPOINT`/`CMD`, rebuild+push+set new image) or is faster as a pure pod-spec `command`/`args` override (no rebuild needed). If you don't own/can't rebuild the image, always prefer overriding via the pod spec — it's a YAML edit, not a build+push round-trip.

**Common Dockerfile edits asked in CKAD-style tasks:**
```dockerfile
FROM nginx:1.25
COPY index.html /usr/share/nginx/html/index.html   # add a static file
ENV APP_ENV=prod                                    # set env baked into image
EXPOSE 8080                                         # documents port, doesn't publish it
ENTRYPOINT ["nginx", "-g", "daemon off;"]
CMD ["-c", "/etc/nginx/nginx.conf"]
```
Rebuild after any Dockerfile edit, then bump the tag and update the workload:
```bash
docker build -t myrepo/app:1.1 .
docker push myrepo/app:1.1
k set image deployment/app app=myrepo/app:1.1
```

## Export/import an image as an OCI-compliant tarball (no registry/push needed)

**Task:** You built an image but have no registry access (common exam constraint) — get it onto the cluster's nodes as a plain file, in the OCI image format.

**Fastest route — buildah/podman (native OCI):**
```bash
podman build -t myrepo/app:1.0 .
podman save --format oci-archive -o app.tar myrepo/app:1.0
```

**Docker CLI equivalent** (Docker's default `docker save` format is Docker's own, not OCI — pass `--format` if your daemon supports it, otherwise convert with `skopeo`):
```bash
docker save -o app.tar myrepo/app:1.0        # Docker archive format
skopeo copy docker-archive:app.tar oci-archive:app-oci.tar:myrepo/app:1.0   # convert to true OCI
```

**Load it back in (on a node, or via containerd directly if that's the runtime):**
```bash
docker load -i app.tar
# or, cluster nodes running containerd (most CKAD clusters, e.g. kind):
ctr -n k8s.io images import app.tar
# or with nerdctl:
nerdctl load -i app.tar
```

**Verify:**
```bash
docker images | grep app
# containerd:
ctr -n k8s.io images ls | grep app
```

**Gotcha:** exam questions phrased as "export the image so it's available to the node without a registry" almost always mean: `save` → copy the tar to the node (`scp`/shared volume) → `load`/`ctr images import` there. Match the tool to the runtime — kind/containerd clusters need `ctr -n k8s.io images import`, not `docker load`, since there's no Docker daemon on the node. Check the runtime first: `k get node <name> -o jsonpath='{.status.nodeInfo.containerRuntimeVersion}'`.

