#!/bin/bash

set -uxo pipefail

LOG_FILE="/var/log/otbr_monitor.log"

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

    local compose_dir="/home/agsense/sysMgmt/config_otbr_docker"
    local compose_file="$compose_dir/docker-compose.yaml"

    if [ ! -f "$compose_file" ]; then
        log_message "ERROR" "Docker compose file not found: $compose_file"
        return 1
    fi

    if [ ! -f "$compose_dir/ot-net-conf.sh" ]; then
        log_message "ERROR" "Script file not found: $compose_dir/ot-net-conf.sh"
        return 1
    fi

    if [ ! -f "$compose_dir/otbr-env.list" ]; then
        log_message "ERROR" "Environment list not found: $compose_dir/otbr-env.list"
        return 1
    fi

    cd "$compose_dir" || {
        log_message "ERROR" "Failed to change to docker-compose directory: $compose_dir"
        return 1
    }

    if docker compose -f "$compose_file" restart; then
        log_message "INFO" "Container restarted successfully"
        sleep 5
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
