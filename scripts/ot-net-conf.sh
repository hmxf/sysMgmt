#!/bin/bash

SUDO=''
if [[ $EUID -ne 0 ]]; then
    SUDO='sudo'
fi

set -x
# 定义间隔时间（秒）
INTERVAL=1
# stop相关命令
{SUDO} ot-ctl thread stop
sleep $INTERVAL
{SUDO} ot-ctl ifconfig down
sleep $INTERVAL

# configure dataset相关命令
{SUDO} ot-ctl dataset init new
# sleep $INTERVAL
# {SUDO} ot-ctl dataset extpanid 299a30126f161acf
# sleep $INTERVAL
# {SUDO} ot-ctl dataset panid 0x7c24
sleep $INTERVAL
{SUDO} ot-ctl dataset channel 17
# sleep $INTERVAL
# {SUDO} ot-ctl dataset networkkey 36724a00a6332b627d35a159efd938e7
sleep $INTERVAL
{SUDO} ot-ctl dataset networkname AgroSensorsNet
sleep $INTERVAL
{SUDO} ot-ctl dataset commit active
sleep $INTERVAL

# configure net prefix相关命令
{SUDO} ot-ctl prefix add fd11:22::/64 pasor
sleep $INTERVAL
{SUDO} ot-ctl ifconfig up
sleep $INTERVAL

# start相关命令
{SUDO} ot-ctl thread start

# 显示网络信息
sleep $INTERVAL
{SUDO} ot-ctl netdata show
{SUDO} ot-ctl dataset  #查看networkkey
{SUDO} ot-ctl networkkey  #查看networkkey

# Default host ipv6 address
{SUDO} ip -6 addr add fd11:22::1:1:1:2333 dev wpan0
