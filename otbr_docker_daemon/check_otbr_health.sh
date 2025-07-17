#!/bin/bash

set -euxo pipefail

LOG_FILE="/var/log/otbr_monitor.log"

log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

check_container_running() {
    if docker ps --format "table {{.Names}}" | grep -q "^otbr$"; then
        return 0
    else
        return 1
    fi
}

check_otbr_network_data() {
    log_message "INFO" "Checking OTBR network data..."
    
    local result
    local exit_code

    if result=$(timeout 30 docker exec -t otbr sh -c '
        (echo "netdata show"; sleep 2; echo "exit") | ot-ctl
    ' 2>&1); then
        exit_code=0
    else
        exit_code=$?
    fi
    
    if [ $exit_code -ne 0 ]; then
        log_message "ERROR" "ot-ctl command failed with exit code $exit_code"
        return 1
    fi

    result=$(echo "$result" | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\r')

    local prefixes_empty=true
    if echo "$result" | sed -n '/^Prefixes:/,/^Routes:/p' | grep -v '^Prefixes:$' | grep -v '^Routes:$' | grep -q '[[:alnum:]]'; then
        prefixes_empty=false
    fi

    local routes_empty=true
    if echo "$result" | sed -n '/^Routes:/,/^Services:/p' | grep -v '^Routes:$' | grep -v '^Services:$' | grep -q '[[:alnum:]]'; then
        routes_empty=false
    fi

    log_message "DEBUG" "Prefixes empty: $prefixes_empty, Routes empty: $routes_empty"

    if $prefixes_empty || $routes_empty; then
        log_message "ERROR" "Critical network data missing"
        return 1
    else
        log_message "SUCCESS" "OTBR network data is healthy"
        return 0
    fi
}

main() {
    log_message "INFO" "Starting OTBR health check..."
    
    if ! check_container_running; then
        log_message "INFO" "OTBR container is not running (may be manually stopped)"
        return 2
    fi

    if check_otbr_network_data; then
        log_message "SUCCESS" "OTBR health check passed"
        return 0
    else
        log_message "ERROR" "OTBR health check failed"
        return 1
    fi
}

main "$@"
