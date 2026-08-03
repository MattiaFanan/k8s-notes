# Multi-Container Pods - In-Depth Mechanics

## Adapter Pattern

### Concept
Containers in the same Pod cannot directly read another container's `stdout`. Although `kubectl logs` surfaces a container's stdout/stderr stream, that stream is not exposed as a file or readable pipe that a sibling container can open. Sidecars therefore integrate with the main application through one of two shared mechanisms:

1. **Shared volume (logs and files):** both containers mount the same `emptyDir` volume. The main app writes log files or artifacts to the volume; the adapter reads (often `readOnly`) from the same path. An `emptyDir` is preferred over `hostPath` because it is pod-scoped and ephemeral, requiring no host filesystem coupling — it survives container restarts within the Pod and is cleaned up automatically when the Pod terminates.

2. **Shared network namespace (API transactions and metrics):** all containers in a Pod share the loopback interface, so they communicate over `localhost`. For example, the main app exposes its raw output on port `7000`, the adapter listens on `7000`, transforms the data, and re-publishes on port `9000`, which the outside world scrapes.

The **Adapter Pattern** uses a sidecar container to transform the main application's output, metrics, or monitoring interface into a format consumable by external systems. The adapter "wraps" the application to make it compatible with the surrounding ecosystem without modifying the application itself.

This pattern embodies the **separation of concerns**: the application focuses on business logic, while the adapter handles external integration details.

### Architecture

```mermaid
graph LR
    A[Main Application Container] -->|stderr / metrics endpoint| B[Adapter Sidecar]
    B -->|normalized format| C[Prometheus Pushgateway]
    B -->|structured JSON| D[ELK / Loki Stack]
    B -->|SNMP format| E[Legacy Monitoring System]
    
    style A fill:#f9f,color:#000,stroke:#333,stroke-width:2px
    style B fill:#bbf,color:#000,stroke:#333,stroke-width:2px
```

### Real-World Example: Legacy Log Adapter

Many legacy applications write logs in a custom binary format or a non-standard text format that the logging stack cannot ingest. Instead of rewriting the application, run an adapter that tails the log file, transforms it, and writes to stdout or a shared volume.

**Kubernetes Manifest:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: legacy-app-with-adapter
spec:
  containers:
  - name: legacy-app
    image: legacy-java-app:1.0
    volumeMounts:
    - name: log-volume
      mountPath: /var/log/app
  - name: log-adapter
    image: fluentd-embeddable:latest
    volumeMounts:
    - name: log-volume
      mountPath: /var/log/app
      readOnly: true
    env:
    - name: FLUENTD_ARGS
      value: "-c /etc/fluentd/config/transform.conf"
  volumes:
  - name: log-volume
    emptyDir: {}
```

The `log-adapter` tail `/var/log/app/app.log`, applies regex transformations or field extractions, and forwards the result to the logging infrastructure.

### Common Adapter Scenarios

| Scenario | What the App Produces | What the Adapter Produces | Adapter Example |
|----------|----------------------|---------------------------|-----------------|
| Custom metrics | `/metrics` in Prometheus format | StatsD, Graphite, or CloudWatch format | `statsd-exporter` wrapping a JMX-only app |
| Legacy logs | COBOL-style fixed-width records | JSON for Loki/Elasticsearch | Custom Fluentd filter |
| SNMP monitoring | Standard HTTP health endpoint | SNMP trap or MIB data | `snmp-exporter` with custom rules |
| Health checks | App outputs CSV diagnostics | Prometheus exporter format | Custom health-to-metrics bridge |

### When to Use

- You cannot modify the main application (legacy code, third-party binary, or vendor constraints).
- You need to bridge between two incompatible monitoring or logging ecosystems.
- You want to decouple the application's internal representation from what the platform expects.

### When NOT to Use

- If you can modify the application to expose the desired format natively (the adapter adds operational overhead).
- If a DaemonSet or cluster-wide agent already handles the transformation for all Pods.

### Best Practices

1. **Share volumes, not networks**: For log adapters, share an `emptyDir` volume rather than relying on stdout capture. EmptyDir gives you durability and file-based streaming semantics.
2. **Use one adapter per concern**: Don't build a "kitchen sink" adapter that transforms logs AND metrics. Keep adapters focused.
3. **Set resource requests**: Adapters are typically I/O bound but may buffer. Set requests to prevent eviction.
4. **Monitor the adapter**: If the adapter crashes, the external system stops receiving data. Alert on adapter health independently.

### Community Knowledge

- **Prometheus Exporters**: The `*-exporter` pattern (e.g., `node_exporter`, `redis_exporter`, `mongodb_exporter`) is the canonical adapter pattern. They scrape a target and re-expose metrics in Prometheus format.
- **OpenTelemetry Collector**: Running the OTel Collector as an adapter allows you to process, filter, and route telemetry from any application before exporting to any backend.
- **CloudWatch Embedded Metric Format (EMF)**: Applications can push JSON to stdout, and a Fluent Bit sidecar extracts structured metrics.

### Common Pitfalls

1. **Adapter becomes the single point of failure**: If the adapter is not robust, data loss occurs. Consider retention logic or retry capabilities in the adapter.
2. **Volume permission mismatches**: The adapter container must have read (or write) permissions on the shared volume. Ensure `fsGroup` or container `securityContext` settings allow access.
3. **Temporal desynchronization**: Logs may arrive at the destination out of order if the adapter buffers. Use sequence numbers or timestamps in transformations.
