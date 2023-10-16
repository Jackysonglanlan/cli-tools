#!/bin/bash
#
# ttl-inc.txt - short script to increase TTL of all packets on port 33434 - 33542
#

/usr/local/sbin/iptables -t mangle -A PREROUTING -p TCP --dport 33434:33542 -j \
TTL --ttl-inc 1
