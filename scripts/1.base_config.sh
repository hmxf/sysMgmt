#!/bin/bash

echo "Update system and install base packages:"

sudo mv /etc/apt/sources.list /etc/apt/sources.list.orig
sudo cp -f ./sources.list /etc/apt/
sudo mv /etc/apt/sources.list.d/raspi.list /etc/apt/sources.list.d/raspi.list.orig
sudo cp -f ./raspi.list /etc/apt/sources.list.d/

sudo apt update -y && sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y
sudo apt upgrade -y raspberrypi-ui-mods
sudo apt install -y gpiod python3-smbus python3-rpi.gpio

echo "Add system configurations:"

SYSTEM_CONFIG=$(cat /boot/firmware/config.txt)

if ! grep -q "dtoverlay=pwm-2chan,pin2=13,func2=4" "$SYSTEM_CONFIG"; then
    sudo echo "dtoverlay=pwm-2chan,pin2=13,func2=4" >> /boot/firmware/config.txt
    echo "'dtoverlay=pwm-2chan,pin2=13,func2=4' has been added in the config file."
else
    echo "'dtoverlay=pwm-2chan,pin2=13,func2=4' already exists in the config file."
fi

if ! grep -q "dtoverlay=i2c-rtc,ds1307" "$SYSTEM_CONFIG"; then
    sudo echo "dtoverlay=i2c-rtc,ds1307" >> /boot/firmware/config.txt
    echo "'dtoverlay=i2c-rtc,ds1307' has been added in the config file."
else
    echo "'dtoverlay=i2c-rtc,ds1307' already exists in the config file."
fi

if ! grep -q "usb_max_current_enable=1" "$SYSTEM_CONFIG"; then
    sudo echo "usb_max_current_enable=1" >> /boot/firmware/config.txt
    echo "'usb_max_current_enable=1' has been added in the config file."
else
    echo "'usb_max_current_enable=1' already exists in the config file."
fi

PSU_MAX_CURRENT=$(sudo rpi-eeprom-config)

if ! grep -q "PSU_MAX_CURRENT=5000" "$PSU_MAX_CURRENT"; then
    echo "PSU_MAX_CURRENT=5000 did not exist in the config file. Please add it manually."
    read -p "Press enter to open editor, then add 'PSU_MAX_CURRENT=5000' to it(3)."
    read -p "Press enter to open editor, then add 'PSU_MAX_CURRENT=5000' to it(2)."
    read -p "Press enter to open editor, then add 'PSU_MAX_CURRENT=5000' to it(1)."
    sudo rpi-eeprom-config -e
else
    echo "PSU_MAX_CURRENT=5000 already exists in the config file."
fi

echo "After this, please reboot your system to take effect!"
