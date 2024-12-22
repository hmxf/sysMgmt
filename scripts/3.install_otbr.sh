#!/bin/bash

# Load iptables kernel module
sudo modprobe ip6table_filter

# Pull the latest OTBR Docker image
docker pull openthread/otbr:latest

# Fetch ttyACM device list
TTY_DEVICES=$(ls /dev | grep ttyACM)

# Get VID, PID and name of the device
get_device_info() {
    local TTY_DEVICE=$1
    DEV_PATH=$(udevadm info -q path -n /dev/$TTY_DEVICE)
    VID=$(udevadm info -a -p $DEV_PATH | grep "idVendor" | head -n1 | awk '{print substr($NF, length($NF)-4, 4)}')
    PID=$(udevadm info -a -p $DEV_PATH | grep "idProduct" | head -n1 | awk '{print substr($NF, length($NF)-4, 4)}')
    VENDOR_NAME=$(udevadm info -a -p $DEV_PATH | grep " ATTRS{manufacturer}" | head -n1 | awk -F'"' '{print $2}')
    PRODUCT_NAME=$(udevadm info -a -p $DEV_PATH | grep "ATTRS{product}" | head -n1 | awk -F'"' '{print $2}')
}

# Check and select ttyACM device
if [ $(echo "$TTY_DEVICES" | wc -l) -gt 1 ]; then
    echo "Multiple ttyACM devices detected, Please select ONE:"

    DEVICE_OPTIONS=()

    for TTY_DEVICE in $TTY_DEVICES; do
        get_device_info $TTY_DEVICE
        DEVICE_OPTIONS+=("$TTY_DEVICE: ID $VID:$PID $VENDOR_NAME $PRODUCT_NAME")
    done

    select DEVICE_OPTION in "${DEVICE_OPTIONS[@]}"; do
        if [ -n "$DEVICE_OPTION" ]; then
            TTY_DEVICE=$(echo "$DEVICE_OPTION" | cut -d: -f1)
            get_device_info $TTY_DEVICE
            break
        else
            echo "Invalid selection, please select again."
        fi
    done
    echo "'/dev/$TTY_DEVICE' was selected as ttyACM device. VID=$VID, PID=$PID, Device=$VENDOR_NAME $PRODUCT_NAME"
elif [ -n "$TTY_DEVICES" ]; then
    TTY_DEVICE=$TTY_DEVICES
    get_device_info $TTY_DEVICE
    echo "'/dev/$TTY_DEVICE' was selected as ttyACM device. VID=$VID, PID=$PID, Device=$VENDOR_NAME $PRODUCT_NAME"
else
    echo "'/dev/ttyACM' device does not exist, stopping."
    exit 1
fi

# Create log directory and log file
mkdir -p ~/.log
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
LOG_FILE="~/.log/otbr_$TIMESTAMP.log"

# Run command in background with screen, redirect outputs to log file
screen -dmS otbr_session -L -Logfile $LOG_FILE bash -c 'docker run --restart=always --sysctl "net.ipv6.conf.all.disable_ipv6=0 net.ipv4.conf.all.forwarding=1 net.ipv6.conf.all.forwarding=1" -p 8080:80 --dns=127.0.0.1 -it --volume /dev/$TTY_DEVICE:/dev/$TTY_DEVICE --privileged openthread/otbr --radio-url spinel+hdlc+uart:///dev/$TTY_DEVICE'

echo "OTBR Docker container is running in the background. Log file: $LOG_FILE"
echo "Use 'screen -r otbr_session' to attach to the session and observe the output."
