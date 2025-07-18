#!/bin/bash

set -uxo pipefail

LOG_FILE="/var/log/otbr_monitor.log"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

is_manually_stopped() {
    if docker ps -a --format "table {{.Names}}\t{{.Status}}" | grep "^otbr" | grep -q "Exited"; then

        local last_logs=$(docker logs otbr --tail 10 2>/dev/null || echo "")
        if echo "$last_logs" | grep -q "SIGTERM\|SIGKILL"; then
            return 0
        fi
    fi
    return 1
}

restart_container() {
    log_message "INFO" "Restarting OTBR container due to health check failure..."
    log_message "INFO" "Container restart initiated"

    cd /home/agsense/sysMgmt/config_otbr_docker
    if docker compose restart otbr; then
        log_message "INFO" "Container restarted successfully"
        sleep 15
        return 0
    else
        log_message "ERROR" "Failed to restart container"
        return 1
    fi
}

main() {
    log_message "INFO" "Restart script called"

    if is_manually_stopped; then
        log_message "INFO" "Container appears to be manually stopped, skipping restart"
        return 0
    fi

    restart_container
    return $?
}

main "$@"
