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

## Dockerfile / Containerfile Syntax

The CKAD exam assumes working knowledge of container images. Understanding `Dockerfile` and `Containerfile` syntax is part of DB-01 (Define, build and modify container images).

### Basic Dockerfile Structure

```dockerfile
# Base image
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy application source
COPY . .

# Expose port
EXPOSE 3000

# Run as non-root user
USER node

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:3000/health || exit 1

# Entry point
CMD ["node", "server.js"]
```

### Key Dockerfile Instructions

| Instruction | Purpose | CKAD Relevance |
|-------------|---------|----------------|
| `FROM` | Base image | Always use specific tags, not `latest` |
| `WORKDIR` | Set working directory | Avoids `cd` in shell commands |
| `COPY` | Copy files from build context | Use `.dockerignore` to exclude unnecessary files |
| `RUN` | Execute shell commands | Use `npm ci` instead of `npm install` for reproducible builds |
| `EXPOSE` | Document listening port | Does not publish the port; use `kubectl expose` or Service |
| `ENV` | Set environment variables | Can be overridden at runtime with `env` in Pod spec |
| `USER` | Set UID for the process | Essential for security; avoid running as root |
| `HEALTHCHECK` | Define container health check | Provides liveness probe equivalent at container level |
| `CMD` | Default command | Can be overridden at runtime |
| `ENTRYPOINT` | Immutable command prefix | Use exec form for signal handling |
| `ARG` | Build-time variables | Not available at runtime |
| `LABEL` | Metadata | Use for version, maintainer, description |

### Multi-Stage Builds

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

### .dockerignore

A `.dockerignore` file excludes files from the build context, reducing image size and build time:

```
node_modules
.git
*.md
.env
Dockerfile
.dockerignore
```

### Image Tagging Best Practices

- Use semantic versioning (`v1.2.3`) or Git SHA (`abc123def`) for immutable references.
- Avoid `:latest` in production — it makes rollbacks difficult and introduces non-determinism.
- Use digest references (`@sha256:...`) for maximum reproducibility.

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

## Image Scanning and Security

Container images should be scanned for vulnerabilities before deployment. Scanning tools analyze image layers against known vulnerability databases (CVEs) and produce severity reports.

### Trivy

Trivy is a widely used open-source scanner that detects OS package vulnerabilities, misconfigurations, and secrets in container images.

```bash
# Scan an image for vulnerabilities
trivy image nginx:1.25

# Scan with severity filter
trivy image --severity HIGH,CRITICAL nginx:1.25

# Scan a local Dockerfile
trivy config .
```

### Snyk

Snyk provides container image scanning with integration into CI/CD pipelines. It offers both free and enterprise tiers.

```bash
# Scan an image with Snyk CLI
snyk container test nginx:1.25
```

### Docker Scout

Docker Scout is Docker's built-in image scanning tool, integrated with Docker Hub.

```bash
# Scan an image with Docker Scout
docker scout quickview nginx:1.25
```

### Scanning Best Practices

- Scan images in CI/CD pipelines before pushing to production registries.
- Use severity thresholds (e.g., block HIGH and CRITICAL) to prevent vulnerable images from being deployed.
- Prefer images from trusted base images (distroless, Alpine) that have smaller attack surfaces.
- Use image digests (`@sha256:...`) to ensure the scanned image is exactly what gets deployed.

## Exam Relevance

- DB-01 (Define, build and modify container images) is in CKAD scope.
- Know image reference formats and how they affect `imagePullPolicy`.
- Know how to create and reference ImagePullSecrets.
- Understand the difference between tag-based and digest-based references.
- Understand Dockerfile/Containerfile syntax (FROM, WORKDIR, COPY, RUN, EXPOSE, USER, CMD, ENTRYPOINT).
- Understand multi-stage builds for smaller image sizes.

## Common Pitfalls

1. **Using `:latest` in production**: Makes rollbacks impossible and introduces non-determinism.
2. **Forgetting `imagePullPolicy: Always` with `:latest`**: The kubelet defaults to `Always` for `:latest`, but being explicit avoids confusion.
3. **ImagePullSecret in wrong namespace**: Secrets must be in the same namespace as the pod.
4. **Wrong registry credentials**: Verify the Docker config JSON is correct and the secret type is `kubernetes.io/dockerconfigjson`.
5. **Running as root**: Always set `USER` in the Dockerfile to avoid running containers as root.
6. **Missing `.dockerignore`**: Large build contexts slow down builds and increase image size.

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