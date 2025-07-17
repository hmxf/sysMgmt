#!/bin/bash

set -euxo pipefail

# Install and configure OTBR software stack
cd ~
git clone https://github.com/openthread/ot-br-posix.git --depth 1
cd ot-br-posix
./script/bootstrap
INFRA_IF_NAME=eth0 ./script/setup
