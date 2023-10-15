### Ping scans the network

```bash
nmap -sP 192.168.0.0/24
```

### Show only open ports

```bash
nmap -F --open 192.168.0.0/24
```

### Full TCP port scan using with service version detection

```bash
nmap -p 1-65535 -sV -sS -T4 192.168.0.0/24
```

### Nmap scan and pass output to Nikto

```bash
nmap -p80,443 192.168.0.0/24 -oG - | nikto.pl -h -
```

### Recon specific ip:service with Nmap NSE scripts stack

```bash
# Set variables:
_hosts="192.168.250.10"
_ports="80,443"

# Set Nmap NSE scripts stack:
_nmap_nse_scripts="+dns-brute,\
                   +http-auth-finder,\
                   +http-chrono,\
                   +http-cookie-flags,\
                   +http-cors,\
                   +http-cross-domain-policy,\
                   +http-csrf,\
                   +http-dombased-xss,\
                   +http-enum,\
                   +http-errors,\
                   +http-git,\
                   +http-grep,\
                   +http-internal-ip-disclosure,\
                   +http-jsonp-detection,\
                   +http-malware-host,\
                   +http-methods,\
                   +http-passwd,\
                   +http-phpself-xss,\
                   +http-php-version,\
                   +http-robots.txt,\
                   +http-sitemap-generator,\
                   +http-shellshock,\
                   +http-stored-xss,\
                   +http-title,\
                   +http-unsafe-output-escaping,\
                   +http-useragent-tester,\
                   +http-vhosts,\
                   +http-waf-detect,\
                   +http-waf-fingerprint,\
                   +http-xssed,\
                   +traceroute-geolocation.nse,\
                   +ssl-enum-ciphers,\
                   +whois-domain,\
                   +whois-ip"

# Set Nmap NSE script params:
_nmap_nse_scripts_args="dns-brute.domain=${_hosts},http-cross-domain-policy.domain-lookup=true,"
_nmap_nse_scripts_args+="http-waf-detect.aggro,http-waf-detect.detectBodyChanges,"
_nmap_nse_scripts_args+="http-waf-fingerprint.intensive=1"

# Perform scan:
nmap --script="$_nmap_nse_scripts" --script-args="$_nmap_nse_scripts_args" -p "$_ports" "$_hosts"
```

## What is Nmap and what is it used for?

From the man page:

> Nmap (“Network Mapper”) is an open source tool for network exploration and security auditing. It was designed to rapidly scan large networks, although it works fine against single hosts. Nmap uses raw IP packets in novel ways to determine what hosts are available on the network, what services (application name and version) those hosts are offering, what operating systems (and OS versions) they are running, what type of packet filters/firewalls are in use, and dozens of other characteristics. While Nmap is commonly used for security audits, many systems and network administrators find it useful for routine tasks such as network inventory, managing service upgrade schedules, and monitoring host or service uptime.

It was originally written by Gordon Lyon and it can answer the following questions easily:

1.  What computers did you find running on the local network?
2.  What IP addresses did you find running on the local network?
3.  What is the operating system of your target machine?
4.  Find out what ports are open on the machine that you just scanned?
5.  Find out if the system is infected with malware or virus.
6.  Search for unauthorized servers or network service on your network.
7.  Find and remove computers which don’t meet the organization’s minimum level of security.

## Sample setup (LAB)

Port scanning may be illegal in some jurisdictions. So setup a lab as follows:

```txt
                              +---------+
        +---------+           | Network |         +--------+
        | server1 |-----------+ switch  +---------|server2 |
        +---------+           | (sw0)   |         +--------+
                              +----+----+
                                   |
                                   |
                         +---------+----------+
                         | wks01 Linux/OSX    |
                         +--------------------+
```

Where,

- wks01 is your computer either running Linux/OS X or Unix like operating system. It is used for scanning your local network. The nmap command must be installed on this computer.
- server1 can be powered by Linux / Unix / MS-Windows operating systems. This is an unpatched server. Feel free to install a few services such as a web-server, file server and so on.
- server2 can be powered by Linux / Unix / MS-Windows operating systems. This is a [fully patched server with firewall](//www.cyberciti.biz/tips/linux-iptables-examples.html 'See how to setup Linux firewall'). Again, feel free to install few services such as a web-server, file server and so on.
- All three systems are connected via switch.

## 1. Scan a single host or an IP address (IPv4)

```bash
### Scan a single ip address ###
nmap 192.168.1.1

## Scan a host name ###
nmap server1.cyberciti.biz

## Scan a host name with more info###
nmap -v server1.cyberciti.biz
```

## 2. Scan multiple IP address or subnet (IPv4)

```bash
nmap 192.168.1.1 192.168.1.2 192.168.1.3
## works with same subnet i.e. 192.168.1.0/24
nmap 192.168.1.1,2,3

# You can scan a range of IP address too:
nmap 192.168.1.1-20

# You can scan a range of IP address using a wildcard:
nmap 192.168.1.*

# Finally, you scan an entire subnet:
nmap 192.168.1.0/24
```

## 4. Excluding hosts/networks (IPv4)

```bash
nmap 192.168.1.0/24 --exclude 192.168.1.5
nmap 192.168.1.0/24 --exclude 192.168.1.5,192.168.1.254

# OR exclude list from a file called /tmp/exclude.txt

nmap -iL /tmp/scanlist.txt --excludefile /tmp/exclude.txt
```

## 5. Turn on OS and version detection scanning script (IPv4)

```bash
nmap -A 192.168.1.254
nmap -v -A 192.168.1.1
nmap -A -iL /tmp/scanlist.txt
```

## 6. Find out if a host/network is protected by a firewall

```bash
nmap -sA 192.168.1.254
nmap -sA server1.cyberciti.biz
```

## 7. Scan a host when protected by the firewall

```bash
nmap -PN 192.168.1.1
nmap -PN server1.cyberciti.biz
```

## 8. Scan an IPv6 host/address

The -6 option enable IPv6 scanning.

```bash
nmap -6 IPv6-Address-Here
nmap -6 server1.cyberciti.biz
nmap -6 2607:f0d0:1002:51::4
nmap -v A -6 2607:f0d0:1002:51::4
```

## 9. Scan a network and find out which servers and devices are up and running

This is known as host discovery or ping scan:

```bash
nmap -sP 192.168.1.0/24
```

## 10. How do I perform a fast scan?

```bash
nmap -F 192.168.1.1
```

## 11. Display the reason a port is in a particular state

```bash
nmap --reason 192.168.1.1
nmap --reason server1.cyberciti.biz
```

## 12. Only show open (or possibly open) ports

```bash
nmap --open 192.168.1.1
nmap --open server1.cyberciti.biz
```

## 13. Show all packets sent and received

```bash
nmap --packet-trace 192.168.1.1
nmap --packet-trace server1.cyberciti.biz
```

## 14. Show host interfaces and routes

```bash
nmap --iflist
```

## 15. How do I scan specific ports?

```bash
nmap -p [port] hostName
## Scan port 80
nmap -p 80 192.168.1.1

## Scan TCP port 80
nmap -p T:80 192.168.1.1

## Scan UDP port 53
nmap -p U:53 192.168.1.1

## Scan two ports ##
nmap -p 80,443 192.168.1.1

## Scan port ranges ##
nmap -p 80-200 192.168.1.1

## Combine all options ##
nmap -p U:53,111,137,T:21-25,80,139,8080 192.168.1.1
nmap -p U:53,111,137,T:21-25,80,139,8080 server1.cyberciti.biz
nmap -v -sU -sT -p U:53,111,137,T:21-25,80,139,8080 192.168.1.254

## Scan all ports with * wildcard ##
nmap -p "*" 192.168.1.1

## Scan top ports i.e. scan $number most common ports ##
nmap --top-ports 5 192.168.1.1
nmap --top-ports 10 192.168.1.1
```

## 16. The fastest way to scan all your devices/computers for open ports ever

```bash
nmap -T5 192.168.1.0/24
```

## 17. How do I detect remote operating system?

You can identify a remote host apps and OS using the -O option

```bash
nmap -O 192.168.1.1
nmap -O  --osscan-guess 192.168.1.1
nmap -v -O --osscan-guess 192.168.1.1

nmap -O 192.168.1.1 nmap -O --osscan-guess 192.168.1.1 nmap -v -O --osscan-guess 192.168.1.1
```

## 18. How do I detect remote services (server / daemon) version numbers?

```bash
nmap -sV 192.168.1.1
```

## 19. Scan a host using TCP ACK (PA) and TCP Syn (PS) ping

If firewall is blocking standard ICMP pings, try the following host discovery methods:

```bash
nmap -PS 192.168.1.1
nmap -PS 80,21,443 192.168.1.1
nmap -PA 192.168.1.1
nmap -PA 80,21,200-512 192.168.1.1
```

## 20. Scan a host using IP protocol ping

```bash
nmap -PO 192.168.1.1
```

## 21. Scan a host using UDP ping

This scan bypasses firewalls and filters that only screen TCP:

```bash
nmap -PU 2000.2001 192.168.1.1
nmap -PU 192.168.1.1
```

## 22. Find out the most commonly used TCP ports using TCP SYN Scan

```bash
### Stealthy scan ###
nmap -sS 192.168.1.1

### Find out the most commonly used TCP ports using  TCP connect scan (warning: no stealth scan)
###  OS Fingerprinting ###
nmap -sT 192.168.1.1

### Find out the most commonly used TCP ports using TCP ACK scan
nmap -sA 192.168.1.1

### Find out the most commonly used TCP ports using TCP Window scan
nmap -sW 192.168.1.1

### Find out the most commonly used TCP ports using TCP Maimon scan
nmap -sM 192.168.1.1
```

## 23. Scan a host for UDP services (UDP scan)

Most popular services on the Internet run over the TCP protocol. DNS, SNMP, and DHCP are three of the most common UDP services. Use the following syntax to find out UDP services:

```bash
nmap -sU nas03
nmap -sU 192.168.1.1
```

## 24. Scan for IP protocol

This type of scan allows you to determine which IP protocols (TCP, ICMP, IGMP, etc.) are supported by target machines:

```bash
nmap -sO 192.168.1.1
```

## 25. Scan a firewall for security weakness

The following scan types exploit a subtle loophole in the TCP and good for testing security of common attacks:

```bash
## TCP Null Scan to fool a firewall to generate a response ##
## Does not set any bits (TCP flag header is 0) ##
nmap -sN 192.168.1.254

## TCP Fin scan to check firewall ##
## Sets just the TCP FIN bit ##
nmap -sF 192.168.1.254

## TCP Xmas scan to check firewall ##
## Sets the FIN, PSH, and URG flags, lighting the packet up like a Christmas tree ##
nmap -sX 192.168.1.254
```

## 26. Scan a firewall for packets fragments

The -f option causes the requested scan (including ping scans) to use tiny fragmented IP packets. The idea is to split up the TCP header over  
several packets to make it harder for packet filters, intrusion detection systems, and other annoyances to detect what you are doing.

```bash
nmap -f 192.168.1.1
nmap -f fw2.nixcraft.net.in
nmap -f 15 fw2.nixcraft.net.in

## Set your own offset size with the --mtu option ##
nmap --mtu 32 192.168.1.1
```

## 27. Cloak a scan with decoys

The -D option it appear to the remote host that the host(s) you specify as [decoys are scanning the target network too](//www.cyberciti.biz/tips/nmap-hide-ipaddress-with-decoy-ideal-scan.html). Thus their IDS might report 5-10 port scans from unique IP addresses, but they won’t know which IP was scanning them and which were innocent decoys:

```bash
nmap -n -Ddecoy-ip1,decoy-ip2,your-own-ip,decoy-ip3,decoy-ip4 remote-host-ip
nmap -n -D192.168.1.5,10.5.1.2,172.1.2.4,3.4.2.1 192.168.1.5
```

## 28. Scan a firewall for MAC address spoofing

```bash
### Spoof your MAC address ##
nmap --spoof-mac MAC-ADDRESS-HERE 192.168.1.1

### Add other options ###
nmap -v -sT -PN --spoof-mac MAC-ADDRESS-HERE 192.168.1.1


### Use a random MAC address ###
### The number 0, means nmap chooses a completely random MAC address ###
nmap -v -sT -PN --spoof-mac 0 192.168.1.1
```

## 29. How do I save output to a text file?

```bash
nmap 192.168.1.1 > output.txt
nmap -oN /path/to/filename 192.168.1.1
nmap -oN output.txt 192.168.1.1
```

## 30 Scans for web servers and pipes into Nikto for scanning

```bash
nmap -p80 192.168.1.2/24 -oG - | /path/to/nikto.pl -h -
nmap -p80,443 192.168.1.2/24 -oG - | /path/to/nikto.pl -h -
```
