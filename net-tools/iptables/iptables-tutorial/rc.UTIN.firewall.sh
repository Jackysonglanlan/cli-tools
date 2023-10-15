#!/bin/sh
#
# rc.UTIN.firewall - UTIN Firewall script for Linux 2.4.x and iptables
#

########################################################################### <a id="" ></a>
#
# 1. Configuration options.
#

#
# 1.1 Internet Configuration.
#

INET_IP="194.236.50.155"
INET_IFACE="eth0"
INET_BROADCAST="194.236.50.255"

#
# 1.1.1 DHCP
#

#
# 1.1.2 PPPoE
#

#
# 1.2 Local Area Network configuration.
#
# your LAN's IP range and localhost IP. /24 means to only use the first 24
# bits of the 32 bit IP address. the same as netmask 255.255.255.0
#

LAN_IP="192.168.0.2"
LAN_IP_RANGE="192.168.0.0/16"
LAN_IFACE="eth1"

#
# 1.3 DMZ Configuration.
#

#
# 1.4 Localhost Configuration.
#

LO_IFACE="lo"
LO_IP="127.0.0.1"

#
# 1.5 IPTables Configuration.
#

IPTABLES="/usr/sbin/iptables"

#
# 1.6 Other Configuration.
#

########################################################################### <a id="" ></a>
#
# 2. Module loading.
#

#
# Needed to initially load modules
#

**/sbin/depmod** -a

#
# 2.1 Required modules
#

/sbin/modprobe ip_tables
/sbin/modprobe ip_conntrack
/sbin/modprobe iptable_filter
/sbin/modprobe iptable_mangle
/sbin/modprobe iptable_nat
/sbin/modprobe ipt_LOG
/sbin/modprobe ipt_limit
/sbin/modprobe ipt_state

#
# 2.2 Non-Required modules
#

#/sbin/modprobe ipt_owner
#/sbin/modprobe ipt_REJECT
#/sbin/modprobe ipt_MASQUERADE
#/sbin/modprobe ip_conntrack_ftp
#/sbin/modprobe ip_conntrack_irc
#/sbin/modprobe ip_nat_ftp
#/sbin/modprobe ip_nat_irc

########################################################################### <a id="" ></a>
#
# 3. /proc set up.
#

#
# 3.1 Required proc configuration
#

echo "1" > /proc/sys/net/ipv4/ip_forward

#
# 3.2 Non-Required proc configuration
#

#echo "1" > /proc/sys/net/ipv4/conf/all/rp_filter
#echo "1" > /proc/sys/net/ipv4/conf/all/proxy_arp
#echo "1" > /proc/sys/net/ipv4/ip_dynaddr

########################################################################### <a id="" ></a>
#
# 4. rules set up.
#

###### <a id="" ></a>
# 4.1 Filter table
#

#
# 4.1.1 Set policies
#

**$IPTABLES** -P INPUT DROP
**$IPTABLES** -P OUTPUT DROP
**$IPTABLES** -P FORWARD DROP

#
# 4.1.2 Create userspecified chains
#

#
# Create chain for bad tcp packets
#

**$IPTABLES** -N bad_tcp_packets

#
# Create separate chains for ICMP, TCP and UDP to traverse
#

**$IPTABLES** -N allowed
**$IPTABLES** -N tcp_packets
**$IPTABLES** -N udp_packets
**$IPTABLES** -N icmp_packets

#
# 4.1.3 Create content in userspecified chains
#

#
# bad_tcp_packets chain
#

**$IPTABLES -A bad_tcp_packets -p tcp** --tcp-flags SYN,ACK SYN,ACK \
**-m state --state NEW -j REJECT** --reject-with tcp-reset
**$IPTABLES -A bad_tcp_packets -p tcp ! --syn -m state --state NEW** -j LOG \
--log-prefix "New not syn:"
**$IPTABLES -A bad_tcp_packets -p tcp ! --syn -m state --state NEW** -j DROP

#
# allowed chain
#

**$IPTABLES -A allowed -p TCP --syn** -j ACCEPT
**$IPTABLES -A allowed -p TCP -m state --state ESTABLISHED,RELATED** -j ACCEPT
**$IPTABLES -A allowed -p TCP** -j DROP

#
# TCP rules
#

**$IPTABLES -A tcp_packets -p TCP -s 0/0 --dport 21** -j allowed
**$IPTABLES -A tcp_packets -p TCP -s 0/0 --dport 22** -j allowed
**$IPTABLES -A tcp_packets -p TCP -s 0/0 --dport 80** -j allowed
**$IPTABLES -A tcp_packets -p TCP -s 0/0 --dport 113** -j allowed

#
# UDP ports
#

**#$IPTABLES -A udp_packets -p UDP -s 0/0 --source-port 53** -j ACCEPT
**#$IPTABLES -A udp_packets -p UDP -s 0/0 --source-port 123** -j ACCEPT
**#$IPTABLES -A udp_packets -p UDP -s 0/0 --source-port 2074** -j ACCEPT
**#$IPTABLES -A udp_packets -p UDP -s 0/0 --source-port 4000** -j ACCEPT

#
# In Microsoft Networks you will be swamped by broadcasts. These lines
# will prevent them from showing up in the logs.
#

**#$IPTABLES -A udp_packets -p UDP -i $INET_IFACE** -d $INET_BROADCAST \
**#--destination-port 135:139** -j DROP

#
# If we get DHCP requests from the Outside of our network, our logs will
# be swamped as well. This rule will block them from getting logged.
#

**#$IPTABLES -A udp_packets -p UDP -i $INET_IFACE** -d 255.255.255.255 \
**#--destination-port 67:68** -j DROP

#
# ICMP rules
#

**$IPTABLES -A icmp_packets -p ICMP -s 0/0 --icmp-type 8** -j ACCEPT
**$IPTABLES -A icmp_packets -p ICMP -s 0/0 --icmp-type 11** -j ACCEPT

#
# 4.1.4 INPUT chain
#

#
# Bad TCP packets we don't want.
#

**$IPTABLES -A INPUT -p tcp** -j bad_tcp_packets

#
# Rules for special networks not part of the Internet
#

**$IPTABLES -A INPUT -p ALL -i $LO_IFACE -s $LO_IP** -j ACCEPT
**$IPTABLES -A INPUT -p ALL -i $LO_IFACE -s $LAN_IP** -j ACCEPT
**$IPTABLES -A INPUT -p ALL -i $LO_IFACE -s $INET_IP** -j ACCEPT

#
# Rules for incoming packets from anywhere.
#

**$IPTABLES -A INPUT -p ALL -d $INET_IP -m state** --state ESTABLISHED,RELATED \
-j ACCEPT
**$IPTABLES -A INPUT -p TCP** -j tcp_packets
**$IPTABLES -A INPUT -p UDP** -j udp_packets
**$IPTABLES -A INPUT -p ICMP** -j icmp_packets

#
# If you have a Microsoft Network on the outside of your firewall, you may
# also get flooded by Multicasts. We drop them so we do not get flooded by
# logs
#

**#$IPTABLES -A INPUT -i $INET_IFACE -d 224.0.0.0/8** -j DROP

#
# Log weird packets that don't match the above.
#

**$IPTABLES -A INPUT -m limit --limit 3/minute --limit-burst 3** -j LOG \
**--log-level DEBUG** --log-prefix "IPT INPUT packet died: "

#
# 4.1.5 FORWARD chain
#

#
# Bad TCP packets we don't want
#

**$IPTABLES -A FORWARD -p tcp** -j bad_tcp_packets

#
# Accept the packets we actually want to forward
#

**$IPTABLES -A FORWARD -p tcp --dport 21 -i $LAN_IFACE** -j ACCEPT
**$IPTABLES -A FORWARD -p tcp --dport 80 -i $LAN_IFACE** -j ACCEPT
**$IPTABLES -A FORWARD -p tcp --dport 110 -i $LAN_IFACE** -j ACCEPT
**$IPTABLES -A FORWARD -m state --state ESTABLISHED,RELATED** -j ACCEPT

#
# Log weird packets that don't match the above.
#

**$IPTABLES -A FORWARD -m limit --limit 3/minute --limit-burst 3** -j LOG \
**--log-level DEBUG** --log-prefix "IPT FORWARD packet died: "

#
# 4.1.6 OUTPUT chain
#

#
# Bad TCP packets we don't want.
#

**$IPTABLES -A OUTPUT -p tcp** -j bad_tcp_packets

#
# Special OUTPUT rules to decide which IP's to allow.
#

**$IPTABLES -A OUTPUT -p ALL -s $LO_IP** -j ACCEPT
**$IPTABLES -A OUTPUT -p ALL -s $LAN_IP** -j ACCEPT
**$IPTABLES -A OUTPUT -p ALL -s $INET_IP** -j ACCEPT

#
# Log weird packets that don't match the above.
#

**$IPTABLES -A OUTPUT -m limit --limit 3/minute --limit-burst 3** -j LOG \
**--log-level DEBUG** --log-prefix "IPT OUTPUT packet died: "

###### <a id="" ></a>
# 4.2 nat table
#

#
# 4.2.1 Set policies
#

#
# 4.2.2 Create user specified chains
#

#
# 4.2.3 Create content in user specified chains
#

#
# 4.2.4 PREROUTING chain
#

#
# 4.2.5 POSTROUTING chain
#

#
# Enable simple IP Forwarding and Network Address Translation
#

**$IPTABLES -t nat -A POSTROUTING -o $INET_IFACE -j SNAT** --to-source $INET_IP

#
# 4.2.6 OUTPUT chain
#

###### <a id="" ></a>
# 4.3 mangle table
#

#
# 4.3.1 Set policies
#

#
# 4.3.2 Create user specified chains
#

#
# 4.3.3 Create content in user specified chains
#

#
# 4.3.4 PREROUTING chain
#

#
# 4.3.5 INPUT chain
#

#
# 4.3.6 FORWARD chain
#

#
# 4.3.7 OUTPUT chain
#

#
# 4.3.8 POSTROUTING chain
#


