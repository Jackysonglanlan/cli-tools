## Tool: [ngrep](http://ngrep.sourceforge.net/usage.html)

```console
$ ngrep -d eth0 "www.domain.com" port 443
```

- `-d [iface|any]` - set interface
- `[domain]` - set hostname
- `port [1-65535]` - set port number

```console
$ ngrep -d eth0 "www.domain.com" src host 10.240.20.2 and port 443
```

- `(host [ip|hostname])` - filter by ip or hostname
- `(port [1-65535])` - filter by port number

```console
$ ngrep -d eth0 -qt -O ngrep.pcap "www.domain.com" port 443
```

- `-q` - quiet mode (only payloads)
- `-t` - added timestamps
- `-O [filename]` - save output to file, `-I [filename]` - reading from file

```console
$ ngrep -d eth0 -qt 'HTTP' 'tcp'
```

- `HTTP` - show http headers
- `tcp|udp` - set protocol
- `[src|dst] host [ip|hostname]` - set direction for specific node

```console
$ ngrep -l -q -d eth0 -i "User-Agent: curl*"
```

- `-l` - stdout line buffered
- `-i` - case-insensitive search

---

## Tool: [hping3](http://www.hping.org/)

```console
$ hping3 -V -p 80 -s 5050 <scan_type> www.google.com
```

- `-V|--verbose` - verbose mode
- `-p|--destport` - set destination port
- `-s|--baseport` - set source port
- `<scan_type>` - set scan type
  - `-F|--fin` - set FIN flag, port open if no reply
  - `-S|--syn` - set SYN flag
  - `-P|--push` - set PUSH flag
  - `-A|--ack` - set ACK flag (use when ping is blocked, RST response back if the port is open)
  - `-U|--urg` - set URG flag
  - `-Y|--ymas` - set Y unused flag (0x80 - nullscan), port open if no reply
  - `-M 0 -UPF` - set TCP sequence number and scan type (URG+PUSH+FIN), port open if no reply

```console
$ hping3 -V -c 1 -1 -C 8 www.google.com
```

- `-c [num]` - packet count
- `-1` - set ICMP mode
- `-C|--icmptype [icmp-num]` - set icmp type (default icmp-echo = 8)

```console
$ hping3 -V -c 1000000 -d 120 -S -w 64 -p 80 --flood --rand-source <remote_host>
```

- `--flood` - sent packets as fast as possible (don't show replies)
- `--rand-source` - random source address mode
- `-d --data` - data size
- `-w|--win` - winsize (default 64)

---

## Tool: [netcat](http://netcat.sourceforge.net/)

```console
$ nc -kl 5000
```

- `-l` - listen for an incoming connection
- `-k` - listening after client has disconnected
- `>filename.out` - save receive data to file (optional)

```console
$ nc 192.168.0.1 5051 < filename.in
```

- `< filename.in` - send data to remote host

```console
$ nc -vz 10.240.30.3 5000
```

- `-v` - verbose output
- `-z` - scan for listening daemons

```console
$ nc -vzu 10.240.30.3 1-65535
```

- `-u` - scan only udp ports

### Transfer data file (archive)

```console
server> nc -l 5000 | tar xzvfp -
client> tar czvfp - /path/to/dir | nc 10.240.30.3 5000
```

### Launch remote shell

```console
# 1)
server> nc -l 5000 -e /bin/bash
client> nc 10.240.30.3 5000

# 2)
server> rm -f /tmp/f; mkfifo /tmp/f
server> cat /tmp/f | /bin/bash -i 2>&1 | nc -l 127.0.0.1 5000 > /tmp/f
client> nc 10.240.30.3 5000
```

### Simple file server

```console
$ while true ; do nc -l 5000 | tar -xvf - ; done
```

### Simple minimal HTTP Server

```console
$ while true ; do nc -l -p 1500 -c 'echo -e "HTTP/1.1 200 OK\n\n $(date)"' ; done
```

### Simple HTTP Server

> Restarts web server after each request - remove `while` condition for only single connection.

```console
$ cat > index.html << __EOF__
<!doctype html>
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <title></title>
        <meta name="description" content="">
        <meta name="viewport" content="width=device-width, initial-scale=1">
    </head>
    <body>

    <p>

      Hello! It's a site.

    </p>

    </body>
</html>
__EOF__
```

```console
$ server> while : ; do \
(echo -ne "HTTP/1.1 200 OK\r\nContent-Length: $(wc -c <index.html)\r\n\r\n" ; cat index.html;) | \
nc -l -p 5000 \
; done
```

- `-p` - port number

### Simple HTTP Proxy (single connection)

```bash
#!/usr/bin/env bash

if [[ $# != 2 ]] ; then
  printf "%s\\n" \
         "usage: ./nc-proxy listen-port bk_host:bk_port"
fi

_listen_port="$1"
_bk_host=$(echo "$2" | cut -d ":" -f1)
_bk_port=$(echo "$2" | cut -d ":" -f2)

printf "  lport: %s\\nbk_host: %s\\nbk_port: %s\\n\\n" \
       "$_listen_port" "$_bk_host" "$_bk_port"

_tmp=$(mktemp -d)
_back="$_tmp/pipe.back"
_sent="$_tmp/pipe.sent"
_recv="$_tmp/pipe.recv"

trap 'rm -rf "$_tmp"' EXIT

mkfifo -m 0600 "$_back" "$_sent" "$_recv"

sed "s/^/=> /" <"$_sent" &
sed "s/^/<=  /" <"$_recv" &

nc -l -p "$_listen_port" <"$_back" | \
tee "$_sent" | \
nc "$_bk_host" "$_bk_port" | \
tee "$_recv" >"$_back"
```

```console
server> chmod +x nc-proxy && ./nc-proxy 8080 192.168.252.10:8000
  lport: 8080
bk_host: 192.168.252.10
bk_port: 8000

client> http -p h 10.240.30.3:8080
HTTP/1.1 200 OK
Accept-Ranges: bytes
Cache-Control: max-age=31536000
Content-Length: 2748
Content-Type: text/html; charset=utf-8
Date: Sun, 01 Jul 2018 20:12:08 GMT
Last-Modified: Sun, 01 Apr 2018 21:53:37 GMT
```

### Create a single-use TCP or UDP proxy

```console
### TCP -> TCP
$ nc -l -p 2000 -c "nc [ip|hostname] 3000"

### TCP -> UDP
$ nc -l -p 2000 -c "nc -u [ip|hostname] 3000"

### UDP -> UDP
$ nc -l -u -p 2000 -c "nc -u [ip|hostname] 3000"

### UDP -> TCP
$ nc -l -u -p 2000 -c "nc [ip|hostname] 3000"
```

---

## Tool: [gnutls-cli](https://gnutls.org/manual/html_node/gnutls_002dcli-Invocation.html)

### Testing connection to remote host (with SNI support)

```console
$ gnutls-cli -p 443 google.com
```

### Testing connection to remote host (without SNI support)

```console
$ gnutls-cli --disable-sni -p 443 google.com
```

---

## Tool: [socat](http://www.dest-unreach.org/socat/doc/socat.html)

### Testing remote connection to port

```console
$ socat - TCP4:10.240.30.3:22
```

- `-` - standard input (STDIO)
- `TCP4:<params>` - set tcp4 connection with specific params
  - `[hostname|ip]` - set hostname/ip
  - `[1-65535]` - set port number

### Redirecting TCP-traffic to a UNIX domain socket under Linux

```console
$ socat TCP-LISTEN:1234,bind=127.0.0.1,reuseaddr,fork,su=nobody,range=127.0.0.0/8 UNIX-CLIENT:/tmp/foo
```

- `TCP-LISTEN:<params>` - set tcp listen with specific params
  - `[1-65535]` - set port number
  - `bind=[hostname|ip]` - set bind hostname/ip
  - `reuseaddr` - allows other sockets to bind to an address
  - `fork` - keeps the parent process attempting to produce more connections
  - `su=nobody` - set user
  - `range=[ip-range]` - ip range
- `UNIX-CLIENT:<params>` - communicates with the specified peer socket
  - `filename` - define socket

---

## Tool: [p0f](http://lcamtuf.coredump.cx/p0f3/)

### Set iface in promiscuous mode and dump traffic to the log file

```console
$ p0f -i enp0s25 -p -d -o /dump/enp0s25.log
```

- `-i` - listen on the specified interface
- `-p` - set interface in promiscuous mode
- `-d` - fork into background
- `-o` - output file

---

## Tool: [netstat](https://en.wikipedia.org/wiki/Netstat)

### Graph # of connections for each hosts

```console
$ netstat -an | awk '/ESTABLISHED/ { split($5,ip,":"); if (ip[1] !~ /^$/) print ip[1] }' | \
  sort | uniq -c | awk '{ printf("%s\t%s\t",$2,$1) ; for (i = 0; i < $1; i++) {printf("*")}; print "" }'
```

### Monitor open connections for specific port including listen, count and sort it per IP

```console
$ watch "netstat -plan | grep :443 | awk {'print \$5'} | cut -d: -f 1 | sort | uniq -c | sort -nk 1"
```

### Grab banners from local IPv4 listening ports

```console
$ netstat -nlt | grep 'tcp ' | grep -Eo "[1-9][0-9]*" | xargs -I {} sh -c "echo "" | nc -v -n -w1 127.0.0.1 {}"
```
