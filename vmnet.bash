#!/bin/bash

set -xeu

vbr=vbr0
eth0=$1

#Enable forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

#Set 2 layer interface
brctl addbr ${vbr}

ip addr add 172.18.0.1/22 dev ${vbr}

ip link set ${vbr} up || true

iptables -A INPUT -p udp --dport 67:68 --sport 67:68 -i ${vbr} -j ACCEPT
iptables -A FORWARD -i ${vbr} -o ${eth0} -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i ${eth0} -o ${vbr} -m state --state ESTABLISHED,RELATED -j ACCEPT

#Using masquerade instead SNAT
iptables -t nat -A POSTROUTING -o ${eth0} -j MASQUERADE