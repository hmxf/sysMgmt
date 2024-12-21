# Install and configure OTBR software stack

# Fetch OTBR source code
cd ~
git clone https://github.com/openthread/ot-br-posix.git --depth 1

# Configure NPM to install packages globally
sudo apt-get install --no-install-recommends -y nodejs npm
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo "export PATH=~/.npm-global/bin:$PATH" >> ~/.bashrc && source ~/.bashrc
npm list -g --depth=0

# Prepare and install OTBR
cd ot-br-posix
WEB_GUI=1 ./script/bootstrap
INFRA_IF_NAME=end0 WEB_GUI=1 ./script/setup
