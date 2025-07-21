#!/bin/bash

set -euxo pipefail

sudo mkdir -p /var/log
sudo touch /var/log/otbr_monitor.log
sudo touch /var/log/container_monitor.log
sudo chown $USER:$USER /var/log/otbr_monitor.log

sudo cp ./check_otbr_health.sh /usr/local/bin
sudo cp ./monitor_otbr.sh /usr/local/bin
sudo cp ./restart_otbr.sh /usr/local/bin
sudo cp ./container_monitor.sh /usr/local/bin

sudo cp ./otbr-monitor.service /etc/systemd/system/
sudo cp ./otbr-monitor.timer /etc/systemd/system/
sudo cp ./container-monitor.service /etc/systemd/system/

sudo systemctl daemon-reload

sudo systemctl enable otbr-monitor.timer
sudo systemctl start otbr-monitor.timer
sudo systemctl enable container-monitor.service
sudo systemctl start container-monitor.service

echo "OTBR monitoring service installed and started successfully!"
echo "Check status of otbr-monitor.timer with: sudo systemctl status otbr-monitor.timer"
echo "Check status of container-monitor.service with: sudo systemctl status container-monitor.service"
echo "View otbr-monitor.service logs with: journalctl -u otbr-monitor.service"
echo "View container-monitor.service logs with: journalctl -u container-monitor.service"
echo "Manual test: sudo systemctl start otbr-monitor.service"
