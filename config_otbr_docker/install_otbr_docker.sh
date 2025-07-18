#!/bin/bash

set -euxo pipefail

# Pull the latest OTBR Docker image
docker pull openthread/border-router:latest

docker compose up -d

echo "Use 'docker ps -a' to verify if container was running."
echo "Use 'docker exec -it otbr ot-ctl' to start ot-ctl CLI."
echo "Use 'docker logs otbr' to view container logs."
