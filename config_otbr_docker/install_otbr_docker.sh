#!/bin/bash

set -euxo pipefail

# Install and config Docker
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Enable IP forwarding on the host system
./setup_host.sh

# Pull the latest OTBR Docker image
docker pull openthread/border-router:latest

# Run command in background
docker compose up -d
sleep 5

echo "OTBR Docker container is running in the background."
echo "Use 'docker ps -a' to verify if container was running."
echo "Use 'docker exec -it otbr ot-ctl' to start ot-ctl CLI."
echo "Use 'docker logs otbr' to view container logs."
