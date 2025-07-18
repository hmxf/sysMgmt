#!/bin/bash

set -euxo pipefail

# Install and config Docker
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Enable IP forwarding on the host system
./setup_host.sh

echo "OTBR Docker daemon is running in the background."
echo "Restart system to use docker."
