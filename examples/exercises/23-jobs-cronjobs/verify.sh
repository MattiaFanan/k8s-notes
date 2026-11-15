#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
N="-n jobs-23"
j() { get job "$1" $N -o jsonpath="$2"; }
c() { get cronjob reporter $N -o jsonpath="{.spec.$1}"; }
echo "Job batch"
check "completions 6, parallelism 2, backoffLimit 2" eq "$(j batch '{.spec.completions} {.spec.parallelism} {.spec.backoffLimit}')" "6 2 2"
check "activeDeadlineSeconds 120, ttl 600" eq "$(j batch '{.spec.activeDeadlineSeconds} {.spec.ttlSecondsAfterFinished}')" "120 600"
check "6 succeeded"                    eq "$(j batch '{.status.succeeded}')" 6
echo "Job indexed"
check "completionMode Indexed, 3 completions" eq "$(j indexed '{.spec.completionMode} {.spec.completions}')" "Indexed 3"
check "3 succeeded"                    eq "$(j indexed '{.status.succeeded}')" 3
check "logs print index=0,1,2"         eq "$(kubectl logs $N -l job-name=indexed --tail=-1 2>/dev/null | grep -o 'index=[0-9]' | sort | tr '\n' ' ')" "index=0 index=1 index=2 "
echo "Job failer"
check "backoffLimit 1"                 eq "$(j failer '{.spec.backoffLimit}')" 1
check "Failed with BackoffLimitExceeded" eq "$(j failer '{.status.conditions[?(@.type=="Failed")].reason}')" BackoffLimitExceeded
echo "CronJob reporter"
check "schedule */5 * * * *"           eq "$(c schedule)" "*/5 * * * *"
check "timeZone Etc/UTC"               eq "$(c timeZone)" Etc/UTC
check "concurrencyPolicy Forbid"       eq "$(c concurrencyPolicy)" Forbid
check "history limits 2/1"             eq "$(c successfulJobsHistoryLimit)/$(c failedJobsHistoryLimit)" 2/1
check "startingDeadlineSeconds 60"     eq "$(c startingDeadlineSeconds)" 60
check "reporter-manual created from the CronJob" eq "$(j reporter-manual '{.metadata.ownerReferences[0].kind}/{.metadata.ownerReferences[0].name}')" CronJob/reporter
check "reporter-manual succeeded"      eq "$(j reporter-manual '{.status.succeeded}')" 1
check "reporter-manual log says 'report done'" has "$(kubectl logs $N job/reporter-manual 2>/dev/null)" "report done"
summary
