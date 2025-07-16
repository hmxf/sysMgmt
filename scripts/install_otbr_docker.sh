#!/bin/bash

# Enable IP forwarding on the host system
./setup_host.sh

# Pull the latest OTBR Docker image
docker pull openthread/border-router:latest

# Run command in background
docker compose up -d
sleep 5

# Configure the OTBR network settings
#docker exec otbr bash /data/ot-net-conf.sh

# Assign default host ipv6 address
sudo ip -6 addr add fd11:22::1:1:1:2333 dev wpan0

echo "OTBR Docker container is running in the background."
echo "Use 'docker ps -a' to verify if container was running."
echo "Use 'docker exec -it otbr /bin/bash' to access container."
echo "Use 'docker exec -it otbr ot-ctl' to start ot-ctl CLI."
echo "Use 'docker logs otbr' to view container logs."
