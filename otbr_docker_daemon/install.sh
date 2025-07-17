#!/bin/bash

set -euxo pipefail

sudo mkdir -p /var/log
sudo touch /var/log/otbr_monitor.log
sudo chown $USER:$USER /var/log/otbr_monitor.log

sudo cp ./check_otbr_health.sh /usr/local/bin
sudo cp ./monitor_otbr.sh /usr/local/bin
sudo cp ./restart_otbr.sh /usr/local/bin

sudo cp ./otbr-monitor.service /etc/systemd/system/
sudo cp ./otbr-monitor.timer /etc/systemd/system/

sudo systemctl daemon-reload

sudo systemctl enable otbr-monitor.timer
sudo systemctl start otbr-monitor.timer

echo "OTBR monitoring service installed and started successfully!"
echo "Check status with: sudo systemctl status otbr-monitor.timer"
echo "View logs with: journalctl -u otbr-monitor.service -f"
echo "Manual test: sudo systemctl start otbr-monitor.service"
