#!/bin/bash

cd ../

echo "# Install x729-fan.service:"

sed -i 's/pwmchip0/pwmchip2/g' x729-fan.sh && chmod +x *.sh
sudo cp -f ./x729-fan.sh /usr/local/bin/
sudo cp -f ./x729-fan.service /lib/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable x729-fan
sudo systemctl start x729-fan

echo "# Install x729-pwr.service:"
sudo cp -f ./xPWR.sh /usr/local/bin/
sudo cp -f x729-pwr.service /lib/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable x729-pwr
sudo systemctl start x729-pwr

echo "# Prepair software shutdown script:"
sudo cp -f ./xSoft.sh /usr/local/bin/
echo "alias safeSHTDN='sudo /usr/local/bin/xSoft.sh 0 26'" >> ~/.bashrc

echo "# Install hardware RTC:"
sudo apt-get -y remove fake-hwclock
sudo update-rc.d -f fake-hwclock remove
sudo systemctl disable fake-hwclock
sudo cp -f ./scripts/hwclock-set /lib/udev/

echo "Finsied, please reboot your system to take effect!"
echo "After reboot, you can use 'safeSHTDN' command to shutdown your system safely."
