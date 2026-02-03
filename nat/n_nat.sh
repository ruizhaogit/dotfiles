#!/bin/bash
# use the ip address of a: 192.168.xx.xxx
# chmod +x n_nat.sh
# sudo bash n_nat.sh
ip route add default via 192.168.xx.xxx
ip route change default via 192.168.xx.xxx dev eth0 advmss 1400
