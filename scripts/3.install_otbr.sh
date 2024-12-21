# Install and configure OTBR software stack

# Fetch OTBR source code
cd ~
git clone https://github.com/openthread/ot-br-posix.git --depth 1

# Configure NPM Mirror
npm config set registry https://registry.npmmirror.com

# Prepare and install OTBR
cd ot-br-posix
WEB_GUI=1 ./script/bootstrap
INFRA_IF_NAME=end0 WEB_GUI=1 ./script/setup
