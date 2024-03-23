#!/bin/bash

# Uninstall x729-fan.service:
sudo systemctl stop x729-fan
sudo systemctl disable x729-fan

file_path="/lib/systemd/system/x729-fan.service"
if [ -f "$file_path" ]; then    
    sudo rm -f "$file_path"    
fi

file_path="/usr/local/bin/x729-fan.sh"
if [ -f "$file_path" ]; then    
    sudo rm -f "$file_path"    
fi

sudo sed -i '/dtoverlay=pwm-2chan/d' /boot/firmware/config.txt

# Uninstall x729 installation script
sudo systemctl stop x729-pwr
sudo systemctl disable x729-pwr
file_path="/lib/systemd/system/x729-pwr.service"
if [ -f "$file_path" ]; then    
    sudo rm -f "$file_path"    
fi

file_path="/usr/local/bin/x729-pwr.sh"
if [ -f "$file_path" ]; then    
    sudo rm -f "$file_path"    
fi

file_path="/usr/local/bin/xgpio_pwr"

if [ -f "$file_path" ]; then    
    sudo rm -f "$file_path"    
fi

# Remove the xoff allias on .bashrc file
sudo sed -i '/x729off/d' ~/.bashrc
source ~/.bashrc

file_path="/usr/local/bin/x729-softsd.sh"
if [ -f "$file_path" ]; then    
    sudo rm -f "$file_path"    
fi

file_path="/usr/local/bin/xgpio_soft"
if [ -f "$file_path" ]; then    
    sudo rm -f "$file_path"    
fi

sudo sed -i '/dtoverlay=pwm-2chan,pin2=13,func2=4/d' /boot/firmware/config.txt
