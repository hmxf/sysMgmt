#!/bin/bash

set -euxo pipefail

echo "Update system and install base packages:"

# Configure software sources
sudo mv /etc/apt/sources.list /etc/apt/sources.list.orig
sudo cp -f ./sources.list /etc/apt/
sudo mv /etc/apt/sources.list.d/raspi.list /etc/apt/sources.list.d/raspi.list.orig
sudo cp -f ./raspi.list /etc/apt/sources.list.d/
sudo cp -f ./no-bookworm-firmware.conf /etc/apt/apt.conf.d/

# Update and upgrade system
sudo apt update -y && sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y

# Install necessary packages
sudo apt upgrade -y raspberrypi-ui-mods
sudo apt install -y gpiod python3-smbus python3-rpi.gpio screen

echo "Add system configurations:"

# Configure sudoers for agsense user
echo "agsense ALL=(ALL:ALL) NOPASSWD: /usr/bin/systemctl*" | sudo EDITOR=tee visudo -f /etc/sudoers.d/agsense

# Configure Git
git config --global core.fileMode false

# Configure SSH
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDhrz08zBncpapwt2jxVhg4UVR18fpHDpSKSe1EdB87x81QQxiZxN3j46q6S1hjoOsaq7GgAKsk0F7DLHSMakcyxU6IuC1xBym7c+cqjx3zcUHmDLZw89YyOGWjdNt6cTPsR7oX46nClAqbAxP5aaqxPZeyy/Zok/PR1Ag7VK+1BIfO5tAiHMfzdgKFt4YSkmhTDYUTSJ6qN2oFy9zYu2HdgMGEuF5CHooKVFZnLJrnfuCpejlIJnLnFYtBQpEdhHvAzTIhZOfqwJWNp1g3KFTla7hFcD73fNbctFjpFm0mzkjdWRu4WqG/RPcNcOgJYq3ljzhKw5fJXAi9tL9eBpCo9uW92iZ1XMkZtAkBA52A7rifICluvqL07kYxy8luAe6WyvhqKxE8Ke8s8jKvZ8QlM5Cbp0ihRW0WDMBxNzV+/RpDzOP3SLtHP/rV1fq1Z2vMsmhDGxHrLMcHTM94Rp8/jcfbEnafoeki9GnUAl+u+WRQWtIy/rm/lD6rZs46nWU= AgSense-MainStation" > ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
sudo sed -i -E \
    -e '/^[[:space:]]*#?[[:space:]]*PermitRootLogin[[:space:]]/{
        s/^[[:space:]]*#?[[:space:]]*PermitRootLogin[[:space:]].*/PermitRootLogin no/
    }' \
    -e '/^[[:space:]]*#?[[:space:]]*PubkeyAuthentication[[:space:]]/{
        s/^[[:space:]]*#?[[:space:]]*PubkeyAuthentication[[:space:]].*/PubkeyAuthentication yes/
    }' \
    -e '/^[[:space:]]*#?[[:space:]]*AuthorizedKeysFile[[:space:]]/{
        s/^[[:space:]]*#?[[:space:]]*AuthorizedKeysFile[[:space:]].*/AuthorizedKeysFile      .ssh\/authorized_keys/
    }' \
    -e '/^[[:space:]]*#?[[:space:]]*PasswordAuthentication[[:space:]]/{
        s/^[[:space:]]*#?[[:space:]]*PasswordAuthentication[[:space:]].*/PasswordAuthentication no/
    }' \
    /etc/ssh/sshd_config
sudo systemctl restart ssh.service

# Fetch boot configs
SYSTEM_CONFIG=$(grep "dtoverlay" /boot/firmware/config.txt)

# Check and add dtoverlay config for PWM fan control if not exists
if ! echo "$SYSTEM_CONFIG" | grep -q "dtoverlay=pwm-2chan,pin2=13,func2=4"; then
    echo "dtoverlay=pwm-2chan,pin2=13,func2=4" | sudo tee -a /boot/firmware/config.txt
    echo "'dtoverlay=pwm-2chan,pin2=13,func2=4' has been added in the config file."
else
    echo "'dtoverlay=pwm-2chan,pin2=13,func2=4' already exists in the config file."
fi

# Check and add dtoverlay config for RTC if not exists
if ! echo "$SYSTEM_CONFIG" | grep -q "dtoverlay=i2c-rtc,ds1307"; then
    echo "dtoverlay=i2c-rtc,ds1307" | sudo tee -a /boot/firmware/config.txt
    echo "'dtoverlay=i2c-rtc,ds1307' has been added in the config file."
else
    echo "'dtoverlay=i2c-rtc,ds1307' already exists in the config file."
fi

# Check and add dtoverlay config for unlocking USB curren limit if not exists
if ! echo "$SYSTEM_CONFIG" | grep -q "usb_max_current_enable=1"; then
    echo "usb_max_current_enable=1" | sudo tee -a /boot/firmware/config.txt
    echo "'usb_max_current_enable=1' has been added in the config file."
else
    echo "'usb_max_current_enable=1' already exists in the config file."
fi

# Fetch EEPROM configs
PSU_MAX_CURRENT=$(sudo rpi-eeprom-config | grep PSU_MAX)

# Check and add PSU_MAX_CURRENT config if not exists
if ! echo "$PSU_MAX_CURRENT" | grep -q "PSU_MAX_CURRENT=5000"; then
    echo "PSU_MAX_CURRENT=5000 did not exist in the config file. Please add it manually."
    read -p "Press enter to open editor, then add 'PSU_MAX_CURRENT=5000' to it(3)."
    read -p "Press enter to open editor, then add 'PSU_MAX_CURRENT=5000' to it(2)."
    read -p "Press enter to open editor, then add 'PSU_MAX_CURRENT=5000' to it(1)."
    sudo rpi-eeprom-config -e
else
    echo "PSU_MAX_CURRENT=5000 already exists in the config file."
fi

echo "After this, please reboot your system to take effect!"
