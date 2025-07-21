#!/bin/bash

set -uxo pipefail

CONTAINER_NAME_OR_ID="otbr"
RESTART_THRESHOLD=10
TIME_WINDOW=300
CHECK_INTERVAL=30
RESTART_HISTORY=()
LOG_FILE="/var/log/container_monitor.log"

trap 'log "INFO" "Script received termination signal, exiting..."; exit 0' SIGINT SIGTERM

log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

get_restart_count() {
    docker inspect --format '{{.RestartCount}}' "$CONTAINER_NAME_OR_ID" 2>/dev/null
}

is_container_running() {
    docker inspect --format '{{.State.Running}}' "$CONTAINER_NAME_OR_ID" 2>/dev/null
}

restart_docker() {
    log "WARNING" "Attempting to restart Docker service..."
    systemctl restart docker
    sleep 10
}

reboot_system() {
    log "ERROR" "Restarting Docker service did not resolve the issue, rebooting system..."
    sleep 10
    reboot
}

wait_container_running() {
    local timeout=120
    local elapsed=0
    while [ $elapsed -lt $timeout ]; do
        if [ "$(is_container_running)" == "true" ]; then
            log "SUCCESS" "Container is running again"
            return 0
        fi
        sleep 5
        elapsed=$((elapsed+5))
    done
    log "INFO" "Timeout waiting for container to recover"
    return 1
}

if ! docker inspect "$CONTAINER_NAME_OR_ID" &>/dev/null; then
    log "WARNING" "Container $CONTAINER_NAME_OR_ID does not exist"
    exit 1
fi

log "INFO" "Start monitoring container: $CONTAINER_NAME_OR_ID"

LAST_RESTART_COUNT=$(get_restart_count)

while true; do
    CURRENT_RESTART_COUNT=$(get_restart_count)
    if [ -z "$CURRENT_RESTART_COUNT" ]; then
        log "WARNING" "Failed to get container restart count, container may have been removed"
        sleep $CHECK_INTERVAL
        continue
    fi

    if [ "$CURRENT_RESTART_COUNT" -gt "$LAST_RESTART_COUNT" ]; then
        DIFF=$((CURRENT_RESTART_COUNT - LAST_RESTART_COUNT))
        for ((i=0; i<DIFF; i++)); do
            RESTART_HISTORY+=("$(date +%s)")
        done
        log "INFO" "Detected $DIFF container restarts, total restarts: $CURRENT_RESTART_COUNT"
        LAST_RESTART_COUNT=$CURRENT_RESTART_COUNT
    fi

    NOW=$(date +%s)
    NEW_HISTORY=()
    for t in "${RESTART_HISTORY[@]}"; do
        if [ $((NOW - t)) -le $TIME_WINDOW ]; then
            NEW_HISTORY+=("$t")
        fi
    done
    RESTART_HISTORY=("${NEW_HISTORY[@]}")

    if [ "${#RESTART_HISTORY[@]}" -ge "$RESTART_THRESHOLD" ]; then
        log "WARNING" "Container restarted more than $RESTART_THRESHOLD times in 5 minutes, triggering recovery process"
        restart_docker
        sleep 10
        if wait_container_running; then
            log "SUCCESS" "Container recovered after Docker restart, reset counter"
            RESTART_HISTORY=()
        else
            reboot_system
            exit 0
        fi
    fi

    sleep $CHECK_INTERVAL
done
