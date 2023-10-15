#!/bin/bash
#
# sid-owner.txt - Example rule on how the sid-owner match could be used.
#

SID=`ps -eo sid,args |grep httpd |head -n 1 |cut -b 1-5`

/usr/local/sbin/iptables -A OUTPUT -p TCP -m owner --sid-owner $SID -j ACCEPT


