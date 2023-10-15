#!/bin/bash
#
# pid-owner.txt - Example rule on how the pid-owner match could be used.
#
#

PID=`ps aux |grep inetd |head -n 1 |cut -b 10-14`

/usr/local/sbin/iptables -A OUTPUT -p TCP -m owner --pid-owner $PID -j ACCEPT


