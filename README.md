# x729-script
User Guide: https://wiki.geekworm.com/X729-script

Email: support@geekworm.com

# Update
Use gpiod instead of obsolete interface, and suuports ubuntu 23.04 also

## Software shutdown service:

PWM_CHIP=0

BUTTON=26


> /usr/local/bin/xSoft.sh 0 20

## Power management service
PWMCHIP=0

SHUTDOWN=5

BOOT=12

>/usr/local/bin/xPWR.sh 0 5 12

## If working with Raspberry Pi 5 hardware, the following changes need to be made after cloning the file
```
sed -i 's/xSoft.sh 0 26/xSoft.sh 4 26/g' install-sss.sh

sed -i 's/xPWR.sh 0 5 12/xPWR.sh 4 5 12/g' x729-pwr.service
```