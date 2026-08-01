# Container Images in Kubernetes

Container images are the foundation of Kubernetes workloads. Understanding image references, pull policies, and registry authentication is essential for the CKAD exam.

## Image Reference Formats

### Registry/Repo:Tag

The most common format. If no tag is specified, `latest` is used.

```
nginx:1.25
registry.example.com/myapp:v2.1
myregistry:5000/myapp:latest
```

### Registry/Repo@Digest

Uses a content-addressable SHA256 digest for immutable references. This is the most reproducible format.

```
nginx@sha256:abc123def456...
registry.example.com/myapp@sha256:abc123def456...
```

### Short Forms

| Format | Example | Resolves To |
|--------|---------|-------------|
| `image` | `nginx` | `docker.io/library/nginx:latest` |
| `image:tag` | `nginx:1.25` | `docker.io/library/nginx:1.25` |
| `registry/image` | `myregistry/myapp` | `myregistry/myapp:latest` |
| `registry/image:tag` | `myregistry/myapp:v1` | `myregistry/myapp:v1` |
| `registry:port/image` | `myregistry:5000/myapp` | `myregistry:5000/myapp:latest` |
| `registry:port/image:tag` | `myregistry:5000/myapp:v1` | `myregistry:5000/myapp:v1` |

## Image Pull Policies

The `imagePullPolicy` field controls when the kubelet pulls an image.

| Policy | Behavior | When to Use |
|--------|----------|-------------|
| `Always` | Always pull the image | When using `:latest` tag or mutable tags |
| `IfNotPresent` | Pull only if image not on node | When using specific tags (recommended) |
| `Never` | Never pull; use only local image | Air-gapped environments |

### Default imagePullPolicy

- If tag is `:latest` → `Always`
- If tag is specific (e.g., `:1.25`) or digest is used → `IfNotPresent`
- If no tag specified → `:latest` is assumed → `Always`

### Best Practice

Always specify `imagePullPolicy` explicitly and use specific tags or digests:

```yaml
containers:
- name: app
  image: nginx:1.25
  imagePullPolicy: IfNotPresent
```

## Private Registry Authentication

### Creating ImagePullSecrets

```bash
# From Docker config
kubectl create secret docker-registry regcred \
  --docker-server=myregistry.example.com \
  --docker-username=myuser \
  --docker-password=mypassword \
  --docker-email=user@example.com \
  -n myns

# From Docker config JSON file
kubectl create secret docker-registry regcred \
  --dockerconfigjson=/path/to/.docker/config.json \
  -n myns
```

### Referencing ImagePullSecrets in a Pod

```yaml
spec:
  imagePullSecrets:
  - name: regcred
  containers:
  - name: app
    image: myregistry.example.com/myapp:1.0
```

### Attaching ImagePullSecrets to a ServiceAccount

```bash
kubectl patch serviceaccount default -n myns \
  -p '{"imagePullSecrets": [{"name": "regcred"}]}'
```

## Multi-Stage Builds (Conceptual)

Multi-stage builds use multiple `FROM` statements in a Dockerfile to create smaller, more secure images. The CKAD exam does not require building images, but you should understand the concept.

```dockerfile
# Build stage
FROM golang:1.21 AS builder
WORKDIR /app
COPY . .
RUN go build -o myapp .

# Final stage
FROM alpine:3.19
COPY --from=builder /app/myapp /usr/local/bin/myapp
ENTRYPOINT ["myapp"]
```

## Image Scanning and Security

- Scan images for vulnerabilities before deploying (e.g., Trivy, Snyk).
- Use image digests for reproducibility and security.
- Avoid `:latest` in production — it makes rollbacks difficult and introduces non-determinism.

## Exam Relevance

- DB-01 (Define, build and modify container images) is in CKAD scope.
- Know image reference formats and how they affect `imagePullPolicy`.
- Know how to create and reference ImagePullSecrets.
- Understand the difference between tag-based and digest-based references.

## Common Pitfalls

1. **Using `:latest` in production**: Makes rollbacks impossible and introduces non-determinism.
2. **Forgetting `imagePullPolicy: Always` with `:latest`**: The kubelet defaults to `Always` for `:latest`, but being explicit avoids confusion.
3. **ImagePullSecret in wrong namespace**: Secrets must be in the same namespace as the pod.
4. **Wrong registry credentials**: Verify the Docker config JSON is correct and the secret type is `kubernetes.io/dockerconfigjson`.

## Commands

```bash
# Check image pull policy of a running pod
kubectl get pod mypod -n myns -o jsonpath='{.spec.containers[*].imagePullPolicy}'

# Check image of a running pod
kubectl get pod mypod -n myns -o jsonpath='{.spec.containers[*].image}'

# Verify ImagePullSecret exists
kubectl get secret regcred -n myns -o jsonpath='{.type}'
# Expected: kubernetes.io/dockerconfigjson

# Decode ImagePullSecret credentials
kubectl get secret regcred -n myns -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d
```

## See also

- [ImagePullSecrets](../../13-admission-control/2-mechanics/06-imagepullsecrets.md)
- [Pods - YAML Structure](../../02-pods/1-yaml-structure.md)