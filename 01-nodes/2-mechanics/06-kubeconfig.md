# kubeconfig Reference

## Overview

A kubeconfig file is a YAML configuration file that stores information about clusters, users, namespaces, and authentication mechanisms. `kubectl` uses kubeconfig files to find the information it needs to communicate with a Kubernetes API server.

## File Location

By default, `kubectl` looks for a file named `config` in the `$HOME/.kube` directory.

```bash
# Default location
~/.kube/config
```

You can override this via:

| Method | Syntax | Effect |
|--------|--------|--------|
| `--kubeconfig` flag | `kubectl --kubeconfig=/path/to/config` | Use only the specified file (no merging) |
| `KUBECONFIG` env var | `export KUBECONFIG=~/.kube/config:~/.kube/other` | Merge listed files (colon-delimited on Linux/Mac, semicolon on Windows) |
| Default | None | Falls back to `~/.kube/config` |

## Merging Rules

When multiple kubeconfig files are merged (via `KUBECONFIG`), the rules are:

1. Empty filenames are ignored.
2. Files with un-deserializable content produce errors.
3. **The first file to set a particular value or map key wins** — values are never changed after being set.
4. The first file to set `current-context` has its context preserved.
5. If two files specify the same user/cluster name, only values from the first file are used; non-conflicting entries from the second file are discarded.

## kubeconfig YAML Structure

```yaml
apiVersion: v1
kind: Config
preferences: {}
current-context: my-context
clusters:
  - name: my-cluster
    cluster:
      server: https://1.2.3.4:6443
      certificate-authority: /path/to/ca.crt
      certificate-authority-data: <base64-encoded CA cert>
      insecure-skip-tls-verify: false
      tls-server-name: ""
      proxy-url: ""
      disable-compression: false
users:
  - name: my-user
    user:
      client-certificate: /path/to/client.crt
      client-certificate-data: <base64-encoded>
      client-key: /path/to/client.key
      client-key-data: <base64-encoded>
      token: <bearer-token>
      tokenFile: /path/to/token-file
      username: ""
      password: ""
      auth-provider:
        name: oidc
        config:
          idp-issuer-url: https://accounts.google.com
          client-id: kubernetes
          refresh-token: <token>
      exec:
        apiVersion: client.authentication.k8s.io/v1beta1
        command: aws-iam-authenticator
        args:
          - "token"
          - "-i"
          - "my-cluster"
        env: null
        interactiveMode: IfAvailable
        installHint: ""
contexts:
  - name: my-context
    context:
      cluster: my-cluster
      user: my-user
      namespace: default
extensions: null
```

## Top-Level Fields

| Field | Required | Description |
|-------|----------|-------------|
| `apiVersion` | No | Must be `v1` |
| `kind` | No | Must be `Config` |
| `preferences` | No | General CLI preferences (deprecated in v1.34) |
| `clusters` | Yes | List of named cluster configurations |
| `users` | Yes | List of named user/auth configurations |
| `contexts` | Yes | List of named context configurations |
| `current-context` | Yes | Name of the default context to use |
| `extensions` | No | Additional extensibility data |

## Cluster Fields (`cluster` under `clusters[*]`)

| Field | Required | Description |
|-------|----------|-------------|
| `server` | Yes | Kubernetes API server URL (`https://hostname:port`) |
| `tls-server-name` | No | Used to check server certificate. If empty, the hostname used to contact the server is used |
| `insecure-skip-tls-verify` | No | Skip TLS certificate validation (insecure) |
| `certificate-authority` | No | Path to CA cert file |
| `certificate-authority-data` | No | PEM-encoded CA cert data (overrides `certificate-authority`) |
| `proxy-url` | No | URL of proxy for all client requests (`http`, `https`, `socks5`) |
| `disable-compression` | No | Disable response compression for all requests |
| `extensions` | No | Extensibility data |

## User/Auth Fields (`user` under `users[*]`)

| Field | Required | Description |
|-------|----------|-------------|
| `client-certificate` | No | Path to client cert file for TLS |
| `client-certificate-data` | No | PEM-encoded client cert data (overrides `client-certificate`) |
| `client-key` | No | Path to client key file for TLS |
| `client-key-data` | No | PEM-encoded client key data (overrides `client-key`) |
| `token` | No | Bearer token for authentication |
| `tokenFile` | No | Path to file containing bearer token (periodically re-read; takes precedence over `token`) |
| `username` | No | Username for basic authentication |
| `password` | No | Password for basic authentication |
| `auth-provider` | No | Custom auth plugin config (e.g., OIDC, gcloud, azure) |
| `exec` | No | Exec-based auth plugin config (e.g., aws-iam-authenticator, gke-gcloud-auth-plugin) |
| `as` | No | Username to impersonate |
| `as-uid` | No | UID to impersonate |
| `as-groups` | No | Groups to impersonate |
| `as-user-extra` | No | Extra info for impersonated user (`map[string][]string`) |
| `extensions` | No | Extensibility data |

## AuthProviderConfig

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Name of the auth provider |
| `config` | Yes | Map of provider-specific configuration keys |

## ExecConfig

| Field | Required | Description |
|-------|----------|-------------|
| `command` | Yes | Command to execute |
| `args` | No | Arguments passed to the command |
| `env` | No | Additional environment variables |
| `apiVersion` | Yes | Input version (`client.authentication.k8s.io/v1beta1` or `v1alpha1`) |
| `installHint` | Yes | Text shown when executable is missing |
| `provideClusterInfo` | Yes | Whether to pass cluster info to the exec process |
| `interactiveMode` | No | `Never`, `IfAvailable`, or `Always` |

## Context Fields (`context` under `contexts[*]`)

| Field | Required | Description |
|-------|----------|-------------|
| `cluster` | Yes | Name of the cluster for this context |
| `user` | Yes | Name of the user for this context |
| `namespace` | No | Default namespace for unspecified requests |
| `extensions` | No | Extensibility data |

## kubectl config Subcommands

### View

```bash
# Show merged kubeconfig settings
kubectl config view

# Show merged settings with raw certificate data and secrets
kubectl config view -o json

# Show only the current context's settings
kubectl config view --minify

# Show a specific kubeconfig file
kubectl config view --kubeconfig=/path/to/config

# Use multiple kubeconfig files and view merged config
KUBECONFIG=~/.kube/config:~/.kube/kubconfig2 kubectl config view
```

### Current Context

```bash
# Display the current context
kubectl config current-context
```

### Use Context (Switch)

```bash
# Switch to a different context
kubectl config use-context my-context

# Short alias (bash-compatible shells)
kx() { [ "$1" ] && kubectl config use-context "$1" || kubectl config current-context; }
```

### Get Contexts

```bash
# List all contexts with details
kubectl config get-contexts

# List only context names
kubectl config get-contexts -o name
```

### Set Context

```bash
# Set a context with cluster, user, and namespace
kubectl config set-context my-context --cluster=my-cluster --user=my-user --namespace=default

# Modify the current context in place
kubectl config set-context --current --namespace=ggckad-s2

# Set only the user field on an existing context
kubectl config set-context my-context --user=cluster-admin

# Set only the cluster field
kubectl config set-context my-context --cluster=my-cluster
```

### Set Cluster

```bash
# Set the server URL for a cluster
kubectl config set-cluster my-cluster --server=https://1.2.3.4:6443

# Set certificate authority
kubectl config set-cluster my-cluster --certificate-authority=/path/to/ca.crt

# Skip TLS verification
kubectl config set-cluster my-cluster --insecure-skip-tls-verify=true

# Set proxy URL
kubectl config set-cluster my-cluster --proxy-url=http://proxy.example.org:3128

# Set TLS server name
kubectl config set-cluster my-cluster --tls-server-name=kubernetes.default.svc
```

### Set Credentials

```bash
# Basic auth
kubectl config set-credentials my-user --username=admin --password=secret

# Bearer token
kubectl config set-credentials my-user --token=eyJhbGciOiJSUzI1NiIs...

# Client certificate and key
kubectl config set-credentials my-user \
  --client-certificate=/path/to/client.crt \
  --client-key=/path/to/client.key

# OIDC auth provider
kubectl config set-credentials my-user \
  --auth-provider=oidc \
  --auth-provider-arg=idp-issuer-url=https://accounts.google.com \
  --auth-provider-arg=client-id=kubernetes \
  --auth-provider-arg=refresh-token=<refresh_token>

# Exec-based auth (e.g., AWS IAM)
kubectl config set-credentials my-user \
  --exec-command=aws-iam-authenticator \
  --exec-arg=token \
  --exec-arg=-i \
  --exec-arg=my-cluster

# Set client-key-data from raw bytes
kubectl config set users.my-user client-key-data cert_data_here --set-raw-bytes=true
```

### Set (Generic)

```bash
# Set any value using dot-delimited path
kubectl config set clusters.my-cluster.server https://1.2.3.4
kubectl config set contexts.my-context.cluster my-cluster
kubectl config set contexts.my-context.user my-user
kubectl config set contexts.my-context.namespace my-namespace

# Set certificate-authority-data (base64 encoded)
kubectl config set clusters.my-cluster.certificate-authority-data $(echo "cert_data_here" | base64 -i -)
```

### Unset

```bash
# Remove a user from kubeconfig
kubectl config unset users.my-user

# Remove a cluster
kubectl config unset clusters.my-cluster

# Remove a context
kubectl config unset contexts.my-context

# Remove a specific field
kubectl config unset contexts.my-context.namespace
```

### Delete

```bash
# Delete a cluster entry
kubectl config delete-cluster my-cluster

# Delete a context entry
kubectl config delete-context my-context

# Delete a user entry
kubectl config delete-user my-user
```

### Rename

```bash
# Rename a context
kubectl config rename-context old-name new-name
```

### Get Clusters / Users

```bash
# List all clusters
kubectl config get-clusters

# List all users
kubectl config get-users
```

## Loading and Precedence Chain

When `kubectl` connects, it determines the effective config in this order:

### 1. Determine the context to use
1. `--context` command-line flag
2. `current-context` from the merged kubeconfig file
3. Empty (allowed)

### 2. Determine cluster info (first hit wins)
1. Command-line flags: `--server`, `--certificate-authority`, `--insecure-skip-tls-verify`
2. Cluster fields from the merged kubeconfig files
3. If no server location is found, the command fails

### 3. Determine user info (first hit wins)
1. Command-line flags: `--client-certificate`, `--client-key`, `--username`, `--password`, `--token`
2. User fields from the merged kubeconfig files
3. If two conflicting auth techniques are present, the command fails

### 4. For any missing info
- Use default values and potentially prompt for authentication information

## Common Operations

### Switch between clusters/contexts

```bash
# List available contexts
kubectl config get-contexts

# Switch context
kubectl config use-context production

# Verify current context
kubectl config current-context
```

### Add a new cluster to kubeconfig

```bash
kubectl config set-cluster prod-cluster \
  --server=https://prod.example.com:6443 \
  --certificate-authority=/path/to/ca.crt \
  --embed-certs=true
```

### Add a new user

```bash
kubectl config set-credentials prod-user \
  --client-certificate=/path/to/client.crt \
  --client-key=/path/to/client.key
```

### Create a context combining cluster and user

```bash
kubectl config set-context prod-context \
  --cluster=prod-cluster \
  --user=prod-user \
  --namespace=production
```

### Switch and verify

```bash
kubectl config use-context prod-context
kubectl config current-context
kubectl get nodes
```

### Export kubeconfig from kind

```bash
kind get kubeconfig --name dev > ~/.kube/config-kind
# Or merge into existing
kind get kubeconfig --name dev >> ~/.kube/config
```

### Export kubeconfig from k3s

```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
chmod 600 ~/.kube/config
```

### Merge multiple kubeconfig files

```bash
export KUBECONFIG=~/.kube/config:~/.kube/other-config
kubectl config view
```

## File Path References

- File and path references in a kubeconfig file are **relative to the location of the kubeconfig file**.
- File references on the command line are **relative to the current working directory**.
- In `$HOME/.kube/config`, relative paths are stored relatively and absolute paths are stored absolutely.