#!/bin/sh

sudo apt update
sudo apt upgrade

tar -xvf xmr-stak*.tar.xz && rm xmr-stak*.tar.xz

sudo cat /etc/sysctl.conf >> "vm.nr_hugepages=128"
sudo sysctl -p /etc/sysctl.conf

sudo cat /etc/security/limits.conf >> "* soft memlock unlimited       
* hard memlock unlimited"

sudo apt install screen -y

cat ~/.bashrc >> 'alias start="cd ~/xmr-stak-rx-linux* && screen -S miner ./xmr-stak-rx"'

cd ~/xmr-stak-rx-linux* && screen -S miner ./xmr-stak-rx