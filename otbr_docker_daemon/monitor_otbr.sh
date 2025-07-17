#!/bin/bash

set -euxo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HEALTH_CHECK_SCRIPT="$SCRIPT_DIR/check_otbr_health.sh"
RESTART_SCRIPT="$SCRIPT_DIR/restart_otbr.sh"
LOG_FILE="/var/log/otbr_monitor.log"
MAX_RETRY_COUNT=2

log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

main() {
    local retry_count=0
    
    log_message "INFO" "Starting OTBR monitoring cycle..."

    while [ $retry_count -lt $MAX_RETRY_COUNT ]; do
        "$HEALTH_CHECK_SCRIPT"
        local health_result=$?
        
        case $health_result in
            0)
                log_message "SUCCESS" "OTBR is healthy"
                return 0
                ;;
            1)
                retry_count=$((retry_count + 1))
                log_message "WARNING" "Health check failed (attempt $retry_count/$MAX_RETRY_COUNT)"
                
                if [ $retry_count -lt $MAX_RETRY_COUNT ]; then
                    log_message "INFO" "Waiting 10 seconds before retry..."
                    sleep 10
                fi
                ;;
            2)
                log_message "INFO" "Container is not running, monitoring completed"
                return 0
                ;;
            *)
                log_message "ERROR" "Unexpected health check result: $health_result"
                return 1
                ;;
        esac
    done

    log_message "ERROR" "All health checks failed, attempting restart..."
    
    if "$RESTART_SCRIPT"; then
        log_message "INFO" "Restart completed, waiting for stabilization..."
        sleep 30

        "$HEALTH_CHECK_SCRIPT"
        local final_result=$?
        
        if [ $final_result -eq 0 ]; then
            log_message "SUCCESS" "Container restart successful, OTBR is now healthy"
            return 0
        else
            log_message "ERROR" "Container restart completed but health check still fails"
            return 1
        fi
    else
        log_message "ERROR" "Failed to restart container"
        return 1
    fi
}

main "$@"
exit_code=$?

log_message "INFO" "Monitoring cycle completed with exit code: $exit_code"
exit $exit_code
