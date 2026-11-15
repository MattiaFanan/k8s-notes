# 21 – Probes and debugging

Run `./setup.sh` first. Namespace: `probe-21`. Work dir: `exercises/21-probes-debug/work/`.

1. Deployment `shop` (nginx, 2 replicas) never becomes Ready and keeps restarting. Fix its probes:
   - **readinessProbe**: HTTP GET `/` on port 80, every 5s
   - **livenessProbe**: HTTP GET `/` on port 80, every 10s, 3 failures allowed
   - **startupProbe**: HTTP GET `/` on port 80, every 2s, up to 30 failures (gives the app 60s to start)
   The new pods must be Ready with 0 restarts.
2. Pod `crasher` is in CrashLoopBackOff. Find out why from the logs of the **previous** container instance and
   write the error line to `work/crasher.txt`.
3. Pod `app` runs image `pause`, which has no shell. Without restarting it, attach an **ephemeral container** named
   `debugger` (`busybox:1.36`) that can see `app`'s processes (`--target`). From it, list the processes. What is PID 1?
4. Question: what is the difference between liveness and readiness failing?

Check with `./verify.sh`, clean up with `./teardown.sh`.
