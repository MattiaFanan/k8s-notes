# Plugins - Imperative Commands

Quick commands for discovering, configuring, and troubleshooting Kubernetes plugins from the CLI.

## CNI Plugins

```bash
# Verify CNI plugin is running
kubectl get pods -n kube-system -l k8s-app=calico-node

# Check CNI configuration ConfigMap
kubectl get configmap cni-config -n kube-system -o jsonpath='{.data.conf.json}'

# Verify node network is ready
kubectl get node <node> -o jsonpath='{.status.conditions[?(@.type=="NetworkUnavailable")].status}'
# Should be "False" when CNI is healthy
```

## CSI / Storage Plugins

```bash
# Verify CSI driver is deployed
kubectl get pods -n kube-system -l app=csi-ebs-controller
kubectl get pods -n kube-system -l app=csi-ebs-node

# List CSI drivers available in the cluster
kubectl get csidrivers

# Check StorageClass provisioner (identifies the storage plugin)
kubectl get storageclass gp2 -o jsonpath='{.provisioner}'
# ebs.csi.aws.com

# Verify CSI migration is enabled (for in-tree to CSI transition)
kubectl get nodes -o jsonpath='{.items[*].status.features}'
```

## Admission Plugins

```bash
# List enabled admission plugins (requires API server access)
kube-apiserver -h | grep enable-admission-plugins

# Verify a ValidatingWebhookConfiguration is loaded
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations

# Check webhook caBundle and service target
kubectl describe validatingwebhookconfiguration pod-policy.example.com
```

## Authentication Plugins

```bash
# Show current auth info
kubectl config view --minify -o jsonpath='{.users[*].user.auth-provider}'

# List configured auth providers
kubectl config view -o jsonpath='{range .users[*]}{.user.auth-provider.name}{"\n"}{end}'

# Verify ServiceAccount token secret exists
kubectl get secret -n default | grep default-token
```

## Scheduler Plugins

```bash
# Check scheduler configuration for enabled plugins
kubectl get cm kube-scheduler -n kube-system -o jsonpath='{.data.config.yaml}'

# View scheduler logs for plugin decisions
kubectl logs -n kube-system -l component=kube-scheduler --tail=100 | grep -i "plugin"

# Inspect pending pod events for scheduling failures
kubectl describe pod <pending-pod> | grep -A 10 "Events:"
```

## kubectl Plugins

```bash
# List available plugins
kubectl plugin list

# List names only
kubectl plugin list --name-only

# Install Krew (one-time)
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Search plugins
kubectl krew search

# Install plugins
kubectl krew install ctx ns neat whoami tree images stern

# Update all plugins
kubectl krew upgrade

# Show installed plugins
kubectl krew list
```
