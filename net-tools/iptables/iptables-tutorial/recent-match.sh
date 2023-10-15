#!/bin/bash
#
# recent-match.txt - Example rule on how the recent match could be used.
#

iptables -N http-recent
iptables -N http-recent-final
iptables -N http-recent-final1
iptables -N http-recent-final2

iptables -A INPUT -p tcp --dport 80 -j http-recent


#
# http-recent-final, has this connection been deleted from httplist or not?
# 
#
iptables -A http-recent-final -p tcp -m recent --name httplist -j \
http-recent-final1
iptables -A http-recent-final -p tcp -m recent --name http-recent-final -j \
http-recent-final2

#
# http-recent-final1, this chain deletes the connection from the httplist 
# and adds a new entry to the http-recent-final
#
iptables -A http-recent-final1 -p tcp -m recent --name httplist \
--tcp-flags SYN,ACK,FIN FIN,ACK --close -j ACCEPT
iptables -A http-recent-final1 -p tcp -m recent --name http-recent-final \
--tcp-flags SYN,ACK,FIN FIN,ACK --set -j ACCEPT

#
# http-recent-final2, this chain allows final traffic from non-closed host
# and listens for the final FIN and FIN,ACK handshake.
#
iptables -A http-recent-final2 -p tcp --tcp-flags SYN,ACK NONE -m recent \
--name http-recent-final --update -j ACCEPT
iptables -A http-recent-final2 -p tcp --tcp-flags SYN,ACK ACK -m recent \
--name http-recent-final --update -j ACCEPT
iptables -A http-recent-final2 -p tcp -m recent --name http-recent-final \
--tcp-flags SYN,ACK,FIN FIN --update -j ACCEPT
iptables -A http-recent-final2 -p tcp -m recent --name http-recent-final \
--tcp-flags SYN,ACK,FIN FIN,ACK --close -j ACCEPT

#
# http-recent chain, our homebrew state tracking system.
#

# Initial stage of the tcp connection SYN/ACK handshake
iptables -A http-recent -p tcp --tcp-flags SYN,ACK,FIN,RST SYN -m recent \
--name httplist --set -j ACCEPT
iptables -A http-recent -p tcp --tcp-flags SYN,ACK,FIN,RST SYN,ACK -m recent \
--name httplist --update -j ACCEPT
# Note that at this state in a connection, RST packets are legal (see RFC 793).
iptables -A http-recent -p tcp --tcp-flags SYN,ACK,FIN ACK -m recent \
--name httplist --update -j ACCEPT

# Middle stage of tcp connection where data transportation takes place.
iptables -A http-recent -p tcp --tcp-flags SYN,ACK NONE -m recent \
--name httplist --update -j ACCEPT
iptables -A http-recent -p tcp --tcp-flags SYN,ACK ACK -m recent \
--name httplist --update -j ACCEPT

# Final stage of tcp connection where one of the parties tries to close the 
# connection.
iptables -A http-recent -p tcp --tcp-flags SYN,FIN,ACK FIN -m recent \
--name httplist --update -j ACCEPT
iptables -A http-recent -p tcp --tcp-flags SYN,FIN,ACK FIN,ACK -m recent \
--name httplist -j http-recent-final

# Special case if the connection crashes for some reason. Malicious intent or 
# no.
iptables -A http-recent -p tcp --tcp-flags SYN,FIN,ACK,RST RST -m recent \
--name httplist --remove -j ACCEPT
