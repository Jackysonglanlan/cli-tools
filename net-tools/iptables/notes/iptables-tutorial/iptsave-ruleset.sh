#!/bin/bash
#
# iptsave-ruleset.txt - Example script used to create iptables-save data.
#

INET_IFACE="eth0"
INET_IP="195.233.192.1"

LAN_IFACE="eth1"

iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP


iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

iptables -A FORWARD -i $INET_IFACE -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $LAN_IFACE -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

iptables -t nat -A POSTROUTING -o $INET_IFACE -j SNAT --to-source $INET_IP


