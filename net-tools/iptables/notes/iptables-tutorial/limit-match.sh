#!/bin/bash
#
# limit-match.txt - Example rule on how the limit match could be used.
#

iptables -A INPUT -p icmp --icmp-type echo-reply -m limit --limit \
3/minute --limit-burst 5 -j DROP



