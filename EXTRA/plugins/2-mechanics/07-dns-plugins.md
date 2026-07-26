# CoreDNS Plugins

CoreDNS is the default DNS server in Kubernetes. It resolves internal DNS names (e.g., `my-service.my-namespace.svc.cluster.local`) and forwards external DNS queries to upstream resolvers. CoreDNS is configured using a `Corefile` and a chain of plugins.

## CoreDNS Architecture

CoreDNS loads plugins from a configuration file (`Corefile`). Each plugin can intercept DNS queries, modify responses, or forward requests to upstream servers. Plugins are executed in the order they appear in the Corefile.

```mermaid
flowchart TD
    A[DNS Query from Pod] --> B[CoreDNS Server]
    B --> C[Corefile: plugin chain]
    C --> D{Internal or External?}
    D -->|Internal (.svc.cluster.local)| E[kubernetes Plugin]
    E --> F[Return A/AAAA Records]
    D -->|External| G[forward Plugin]
    G --> H[Upstream DNS (e.g., 8.8.8.8)]
    H --> I[Return Response]
    F --> J[DNS Response to Pod]
    I --> J
```

## Corefile Format

The Corefile is a text file that defines how CoreDNS should handle DNS queries for specific zones.

```corefile
. {
    log
    errors
    health :8080
    ready :8181
    prometheus :9153
    
    kubernetes cluster.local in-addr.arpa ip6.arpa {
        pods insecure
        fallthrough in-addr.arpa ip6.arpa
    }
    
    forward . /etc/resolv.conf {
        max_concurrent 1000
    }
    
    cache 30 {
        success 1000
        denial 1000
    }
    
    loop
    reload
}
```

## Common CoreDNS Plugins

### kubernetes

The core plugin that resolves Kubernetes services and pods. It maps service names, namespaces, and endpoints to DNS A/AAAA records.

**Configuration:**

```corefile
kubernetes cluster.local in-addr.arpa ip6.arpa {
    pods insecure
    fallthrough in-addr.arpa ip6.arpa
}
```

**Options:**
- `pods insecure`: Allows A/AAAA records for pod IPs (default in older versions; `pods verified` or `pods disabled` in newer versions).
- `endpoint_pod_names`: Adds pod names as TXT records.
- `ttl`: Default TTL for DNS responses (default: 5 seconds).

**Example DNS records generated:**

| Query | Response |
|-------|----------|
| `my-service.my-namespace.svc.cluster.local` | ClusterIP of the Service |
| `my-pod.my-namespace.pod.cluster.local` | IP of the Pod |
| `kubernetes.default.svc.cluster.local` | ClusterIP of the kubernetes Service |

### forward

Forwards DNS queries for domains not handled by the `kubernetes` plugin to upstream DNS servers.

**Configuration:**

```corefile
forward . 8.8.8.8 8.8.4.4 {
    max_concurrent 1000
    prefer_udp
    expire 10s
}

# Forward specific domains
forward .config /etc/resolv.conf
```

**Options:**
- `max_concurrent`: Maximum concurrent requests per upstream.
- `prefer_udp`: Prefer UDP over TCP for DNS queries.
- `expire`: Timeout for upstream queries.

### cache

Caches DNS responses to reduce latency and upstream DNS load. Cache is per-requestor, so different clients maintain separate caches.

**Configuration:**

```corefile
cache 30 {
    success 1000 30
    denial 1000 5
    prefetch 3 20m
}
```

**Options:**
- `success 1000 30`: Cache successful responses for 30 seconds, up to 1000 entries.
- `denial 1000 5`: Cache negative responses for 5 seconds, up to 1000 entries.
- `prefetch 3 20m`: Prefetch entries when TTL drops below 20% and accessed at least 3 times.

### loop

Detects forwarding loops and prevents infinite recursion. If a loop is detected, CoreDNS logs an error and returns `SERVFAIL`.

**Configuration:**

```corefile
loop
```

**Best practice:** Always include `loop` to catch misconfigurations early.

### errors

Logs errors to standard error output. Useful for debugging DNS issues.

**Configuration:**

```corefile
errors
```

### log

Logs each DNS query and response. Use this for debugging DNS resolution problems.

**Configuration:**

```corefile
log
```

**Example log output:**

```
.:53
10.244.0.5 - 2024/01/15 10:00:00.000 [INFO] 10.244.0.5:12345 - "my-service.my-ns.svc.cluster.local. A IN" 0.000098463s
```

### health

Enables a health check endpoint on a specified address and port.

**Configuration:**

```corefile
health :8080
```

**Usage:**

```bash
curl http://coredns-service.namespace.svc.cluster.local:8080/health
```

### ready

Enables a readiness endpoint. CoreDNS is considered ready when it has successfully loaded the Kubernetes API.

**Configuration:**

```corefile
ready :8181
```

### prometheus

Exposes metrics on a Prometheus endpoint for monitoring.

**Configuration:**

```corefile
prometheus :9153
```

**Key metrics:**
- `coredns_dns_requests_total`: Total DNS requests by plugin and response code.
- `coredns_dns_responses_total`: DNS responses by response code.
- `coredns_forward_healthcheck_broken`: Number of broken healthchecks.

### reload

Watches the Corefile and automatically reloads when changes are detected.

**Configuration:**

```corefile
reload
```

**Options:**
- `interval 5s`: Check for changes every 5 seconds.
- `jitter 2s`: Add random jitter to reload checks.

### hosts

Serves DNS records from a local hosts file, overriding the `kubernetes` plugin for specific entries.

**Configuration:**

```corefile
hosts {
    192.168.1.10 my-custom-host.example.com
    fallthrough
}
```

### auto

Automatically loads zone files from a directory. Useful for serving custom DNS zones.

**Configuration:**

```corefile
auto example.com /etc/coredns/zones/example.com*.db
```

### bind

Binds CoreDNS to a specific interface and port, useful for running multiple CoreDNS instances or restricting access.

**Configuration:**

```corefile
bind 127.0.0.1
```

## Custom DNS in Kubernetes

### Override Pod DNS

You can configure pods to use a custom DNS policy or override DNS servers.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: custom-dns-pod
spec:
  dnsPolicy: None
  dnsConfig:
    nameservers:
      - 8.8.8.8
      - 1.1.1.1
    searches:
      - my-namespace.svc.cluster.local
      - svc.cluster.local
      - cluster.local
    options:
      - name: ndots
        value: "2"
  containers:
    - name: app
      image: alpine
      command: ['sh', '-c', 'sleep 3600']
```

### Stub Domains and Upstream Nameservers

Cluster administrators can configure stub domains and upstream nameservers for specific domains.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-system/coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
            lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
            pods insecure
            fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . /etc/resolv.conf {
            max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
    example.com:53 {
        errors
        cache 30
        forward . 10.0.0.2 10.0.0.3
    }
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-system/kubelet-config
  namespace: kube-system
data:
  kubelet: |
    ...
    resolvConf: /run/systemd/resolve/resolv.conf
```

## Plugin Comparison

| Plugin | Purpose | Required? | Performance Impact |
|--------|---------|-----------|-------------------|
| kubernetes | Internal service resolution | Yes | Low |
| forward | External DNS forwarding | Yes | Medium (depends on upstream) |
| cache | Caching of DNS responses | Recommended | Low (reduces latency) |
| errors | Error logging | Recommended | None |
| log | Query logging | Debug only | Low |
| loop | Loop detection | Recommended | None |
| reload | Auto-reload Corefile | Recommended | Low |
| prometheus | Metrics export | Recommended for monitoring | Low |
| health | Health check endpoint | Recommended | None |
| ready | Readiness endpoint | Recommended | None |
| hosts | Static DNS overrides | Optional | None |
| auto | Dynamic zone loading | Optional | Medium |

## Best Practices

1. **Always include `loop`**: Detects misconfigurations that cause infinite forwarding loops.
2. **Use `cache`**: Reduces DNS latency and upstream load. 30-second TTL is standard.
3. **Enable `reload`**: Allows CoreDNS configuration changes without restarting pods.
4. **Monitor with `prometheus`**: Track DNS latency, errors, and query volume.
5. **Use `forward . /etc/resolv.conf`**: Leverages the node's upstream DNS resolvers.
6. **Set `ndots: 2`**: The default in Kubernetes. Lower values reduce unnecessary DNS queries.
7. **Avoid custom `dnsPolicy` unless necessary**: Use `ClusterFirst` (default) for most workloads.

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `nslookup` fails for internal services | CoreDNS pods not running or Corefile misconfigured | Check CoreDNS pod logs, verify Corefile syntax |
| External DNS resolution slow | No caching or upstream resolver slow | Enable `cache` plugin, check upstream DNS |
| `SERVFAIL` for all queries | Loop detected or upstream unreachable | Check `loop` plugin logs, verify upstream DNS connectivity |
| DNS resolves old IPs after service change | TTL caching stale record | Restart CoreDNS or reduce cache TTL |
| `nslookup` returns `NXDOMAIN` for valid service | Typo in service name or namespace mismatch | Verify service exists: `kubectl get svc -n <ns>` |
| Pod cannot resolve DNS | Pod DNS policy misconfigured or CoreDNS service unavailable | Check pod `dnsPolicy`, verify CoreDNS service and endpoints |

## Commands

```bash
# Check CoreDNS deployment
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl describe pods -n kube-system -l k8s-app=kube-dns

# View Corefile ConfigMap
kubectl get configmap -n kube-system coredns -o yaml

# Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns -c coredns

# Test DNS from inside a pod
kubectl run dnstest --image=busybox --restart=Never --rm -it -- nslookup kubernetes.default
kubectl run dnstest --image=busybox --restart=Never --rm -it -- dig kubernetes.default.svc.cluster.local

# Check CoreDNS metrics
kubectl port-forward -n kube-system svc/kube-dns 9153:9153
curl http://localhost:9153/metrics | grep coredns

# Test CoreDNS health endpoint
kubectl port-forward -n kube-system svc/kube-dns 8080:8080
curl http://localhost:8080/health
curl http://localhost:8181/ready

# Check DNS service configuration
kubectl get svc -n kube-system kube-dns
kubectl get endpoints -n kube-system kube-dns

# Restart CoreDNS after configuration change
kubectl rollout restart deployment -n kube-system coredns
```
