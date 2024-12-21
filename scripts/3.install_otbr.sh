# Install and configure OTBR software stack
cd ~
git clone https://github.com/openthread/ot-br-posix.git --depth 1
cd ot-br-posix
WEB_GUI=1 ./script/bootstrap
INFRA_IF_NAME=end0 WEB_GUI=1 ./script/setup
