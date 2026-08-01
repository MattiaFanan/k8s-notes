# Container Logging Behavior

Kubernetes captures container stdout and stderr output and makes it available for inspection. Understanding how logging works is essential for debugging and monitoring applications.

## Default Logging Mechanism

By default, the container runtime captures all output written to stdout and stderr by the container process and writes it to log files on the node.

### Log File Location

The kubelet stores log files in the following directories:

- `/var/log/pods/<pod-uid>/<container-name>/<container-id>.log` — Raw log files
- `/var/log/containers/<pod-name>_<namespace>_<container-name>-<container-id>.log` — Symlinks to the raw log files

### Log Rotation

The kubelet handles log rotation with the following configuration options:

| Option | Default | Description |
|---|---|---|
| `containerLogMaxSize` | 10Mi | Maximum size of a single log file |
| `containerLogMaxFiles` | 5 | Maximum number of log files to retain per container |
| `podLogs` | — | Directory where pod logs are stored |

```bash
# Check log rotation settings on a node
cat /var/lib/kubelet/config.yaml | grep -A 5 'logging\|containerLog'
```

> **Pitfall**: Log files on the node can fill up disk space. If `containerLogMaxSize` is too large or `containerLogMaxFiles` is too high, nodes can run out of disk. Monitor node disk usage and set appropriate log rotation policies.

## Log Format

Each log line is prefixed with a timestamp:

```
2024-01-15T10:30:00.123456789Z stdout F This is a log line
2024-01-15T10:30:00.123456789Z stderr F This is an error line
```

The format is: `TIMESTAMP STREAM FLAG MESSAGE`

- `stdout` or `stderr`: The stream the log was written to.
- `F` or `P`: Flag indicating the log type (F = first line of a message, P = partial line).
- `MESSAGE`: The actual log content.

## Accessing Logs

### kubectl logs

```bash
# Get logs from the current running container
kubectl logs myapp-pod-abc123 -n production

# Get logs from a previous (crashed) container instance
kubectl logs myapp-pod-abc123 -n production -p

# Stream logs in real-time
kubectl logs myapp-pod-abc123 -n production -f

# Get logs from a specific container in a multi-container pod
kubectl logs myapp-pod-abc123 -n production -c app-container

# Get logs since a specific time
kubectl logs myapp-pod-abc123 -n production --since=1h

# Get logs from the last 30 minutes
kubectl logs myapp-pod-abc123 -n production --since=30m

# Get logs with a timestamp
kubectl logs myapp-pod-abc123 -n production --timestamps

# Get the last 100 lines of logs
kubectl logs myapp-pod-abc123 -n production --tail=100

# Get logs matching a pattern
kubectl logs myapp-pod-abc123 -n production | grep ERROR

# Get logs from all containers in a pod
kubectl logs myapp-pod-abc123 -n production --all-containers
```

> **Pitfall**: `kubectl logs -p` only retrieves logs from the previous terminated container instance. If the container has been restarted multiple times, only the most recent previous instance is available. Older log instances are rotated and may be lost.

## Sidecar Logging Pattern

For production-grade logging control, the sidecar pattern is recommended. A sidecar container reads the application's log output and forwards it to a centralized logging system.

```yaml
spec:
  containers:
    - name: app
      image: myapp:1.0
      stdout:
        redirect:
          path: /var/log/app/app.log
    - name: log-sidecar
      image: fluentd:latest
      volumeMounts:
        - name: logs
          mountPath: /var/log/app
  volumes:
    - name: logs
      emptyDir: {}
```

### Alternative: Shared Volume for Logs

```yaml
spec:
  containers:
    - name: app
      image: myapp:1.0
      volumeMounts:
        - name: logs
          mountPath: /var/log/app
    - name: log-collector
      image: fluentd:latest
      volumeMounts:
        - name: logs
          mountPath: /var/log/app
  volumes:
    - name: logs
      emptyDir: {}
```

> **Best practice**: In production, do not rely solely on node-level log files. Use a sidecar or a log agent (e.g., Fluentd, Fluent Bit, Logstash) to forward logs to a centralized logging system (e.g., Elasticsearch, Loki, Datadog).

## Logging Drivers

The container runtime can use different logging drivers to control how logs are handled:

| Driver | Description |
|---|---|
| `json-file` | Default. Logs stored as JSON files on the node. |
| `journald` | Logs sent to the systemd journal. |
| `fluentd` | Logs sent to a Fluentd agent. |
| `awslogs` | Logs sent to AWS CloudWatch. |
| `gcplogs` | Logs sent to Google Cloud Logging. |
| `splunk` | Logs sent to Splunk. |

```bash
# Check the logging driver on a node
cat /etc/docker/daemon.json
# {"log-driver": "json-file", "log-opts": {"max-size": "10m", "max-file": "5"}}
```

## Best Practices

1. **Log to stdout/stderr**: Applications should write logs to stdout and stderr, not to files on the container filesystem.
2. **Use structured logging**: JSON-formatted logs are easier to parse and query in centralized logging systems.
3. **Implement log rotation**: Configure `containerLogMaxSize` and `containerLogMaxFiles` on the kubelet.
4. **Use a log aggregator in production**: Forward logs to Elasticsearch, Loki, Datadog, or another centralized system.
5. **Include correlation IDs**: Add request IDs or trace IDs to log lines for distributed tracing.
6. **Set appropriate log levels**: Use `INFO` for normal operations, `WARN` for recoverable issues, and `ERROR` for failures.
7. **Avoid logging sensitive data**: Never log passwords, tokens, or PII in log output.

## Troubleshooting

- **No logs returned by `kubectl logs`**: The container may not have written any output to stdout/stderr, or the container may not have started yet.
- **`container not found`**: The container name or ID is incorrect. Check `kubectl get pod <name> -o jsonpath='{.status.containerStatuses[*].name}'`.
- **Logs are truncated**: The log file may have been rotated. Use `kubectl logs -p` to get the previous container instance's logs.
- **Disk full on node**: Log files may have consumed all disk space. Check `df -h /var/log` on the node and adjust `containerLogMaxSize` and `containerLogMaxFiles`.
- **Logs not appearing in centralized system**: The log agent (Fluentd, Fluent Bit, etc.) may not be running or may be misconfigured. Check the agent's pod status and logs.
- **`kubectl logs` hangs**: The container may be producing a large amount of output. Use `--tail` to limit the output.

## Commands

```bash
# Get logs from a running container
kubectl logs myapp-pod-abc123 -n production

# Get logs from a previous container instance
kubectl logs myapp-pod-abc123 -n production -p

# Stream logs in real-time
kubectl logs myapp-pod-abc123 -n production -f

# Get logs from a specific container
kubectl logs myapp-pod-abc123 -n production -c app-container

# Get logs since a specific time
kubectl logs myapp-pod-abc123 -n production --since=1h

# Get the last 100 lines
kubectl logs myapp-pod-abc123 -n production --tail=100

# Get logs with timestamps
kubectl logs myapp-pod-abc123 -n production --timestamps

# Get logs from all containers in a pod
kubectl logs myapp-pod-abc123 -n production --all-containers

# Check log files on the node (SSH to the node)
ls -la /var/log/pods/<pod-uid>/
ls -la /var/log/containers/

# Check kubelet log rotation config
cat /var/lib/kubelet/config.yaml | grep -i 'containerLog'
```