## Tcpdump Flags

| TCP Flag | tcpdump Flag | Meaning                                       |
| :------- | :----------- | :-------------------------------------------- |
| SYN      | `[S]`        | Syn packet, a session establishment request.  |
| ACK      | `[A]`        | Ack packet, acknowledge sender's data.        |
| FIN      | `[F]`        | Finish flag, indication of termination.       |
| RESET    | `[R]`        | Reset, indication of immediate abort of conn. |
| PUSH     | `[P]`        | Push, immediate push of data from sender.     |
| URGENT   | `[U]`        | Urgent, takes precedence over other data.     |
| NONE     | A dot `[.]`  | Placeholder, usually used for ACK.            |

## docs

- https://github.com/NanXiao/tcpdump-little-book
- http://danielmiessler.com/study/tcpdump/

## Filter Packets with Tcp Flags

### Capture packets with A particular TCP Flag

Here are the numbers which match with the corresponding TCP flags.

| Flag | Bit Value |
| :--- | :-------- |
| URG  | 32        |
| ACK  | 16        |
| PSH  | 8         |
| RST  | 4         |
| SYN  | 2         |
| FIN  | 1         |

We can use the following ways to capture packets with syn TCP flag. Syn flag is 00000010 in tcp header. That is 2 in decimal.

```
tcpdump -i utun1 tcp[tcpflags] == 'tcp-syn'
tcpdump -i utun1 tcp[13] == 2
```

The following TCP flag field values are also available: `tcp-fin`, `tcp-syn`, `tcp-rst`, `tcp-push`, `tcp-act`, `tcp-urg`.

If we need to capture PSH packet, can we use the following way to capture it?

`tcpdump -i utun1 tcp[tcpflags] == 'tcp-push'`

See also: [Mastering the Linux Command Line — Your Complete Free Training Guide](https://www.howtouselinux.com/mastering-the-linux-command-line-your-complete-training-guide)

No. All the packets have an ack flag in them except the syn packets. In this case, we need to filter push ack packets for this. We will discuss this in the next part.

This is an example of how to capture packets with syn TCP flag and why.

In TCP/IP protocol, the 13th byte of the TCP header contains a set of control flags. This is also known as the “TCP Flags” field. Each bit in this field represents a specific flag, and the value of that bit indicates whether the flag is set or not.

For example, the second bit from the left in the TCP Flags field represents the `SYN` flag, which is used for the initial synchronization of a connection between two hosts.

| Flag | Bit Value | Binary Value |
| :--- | :-------- | :----------- |
| URG  | 32        | 100000       |
| ACK  | 16        | 010000       |
| PSH  | 8         | 001000       |
| RST  | 4         | 000100       |
| SYN  | 2         | 000010       |
| FIN  | 1         | 000001       |

**TCP Header**

Let's have a closer look at octet no. 13:

```
|---------------|
|C|E|U|A|P|R|S|F|
|7|6|5|4|3|2|1|0|
```

These are the TCP control bits we are interested in. We have numbered the bits in this octet from 0 to 7, right to left, so the `PSH` bit is bit number 3, while the `URG` bit is number 5.

Recall that we want to capture packets with only `SYN` set. Let's see what happens to octet 13 if a TCP datagram arrives with the `SYN` bit set in its header.

```
|C|E|U|A|P|R|S|F|
|---------------|
|0 0 0 0 0 0 1 0|
|---------------|
|7|6|5|4|3|2|1|0|
```

Looking at the control bits section we see that only bit number 1 (`SYN`) is set.

Assuming that octet number 13 is an 8-bit unsigned integer in network byte order, the binary value of this octet is `00000010` and its decimal representation is

$$
0*2^7 + 0*2^6 + 0*2^5 + 0*2^4 + 0*2^3 + 0*2^2 + 1*2^1 + 0*2^0 = 2
$$

We're almost done, because now we know that if only `SYN` is set, the value of the 13th octet in the TCP header, when interpreted as a 8-bit unsigned integer in network byte order, must be exactly 2.

This relationship can be expressed as `'tcp[13] == 2'`

We can use this expression as the filter for tcpdump in order to watch packets which have only `SYN` set: `tcpdump -i xl0 'tcp[13] == 2'`

The expression says: let the 13th octet of a TCP datagram have the decimal value 2, which is exactly what we want.

### Capture packets with a Combination of Tcp Flags

| Flag | Bit Value |
| :--- | :-------- |
| URG  | 32        |
| ACK  | 16        |
| PSH  | 8         |
| RST  | 4         |
| SYN  | 2         |
| FIN  | 1         |

| Flag Combination | Value           |
| :--------------- | :-------------- |
| FIN, ACK         | 17 (1 + 16)     |
| SYN, ACK         | 18 (2 + 16)     |
| PSH, ACK         | 24 (8 + 16)     |
| FIN, PSH         | 9 (1 + 8)       |
| FIN, PSH, ACK    | 25 (1 + 8 + 16) |

We can use the following way to capture syn-ack packets. This is `10010` in binary and 18 in decimal.

`tcpdump -i utun1 'tcp[13] == 18'`

For psh-ack packets, we can use this way. This is `11000` in binary and 24 in decimal.

`tcpdump -i utun1 'tcp[13] == 24'`

If we need to capture syn and syn-ack packets, we can do this in the following ways.

```
tcpdump -i utun1 'tcp[13] == 18 or tcp[13] == 2'
tcpdump -i utun1 'tcp[13] == 18 or tcp[tcpflags] == "tcp-syn"'
tcpdump -i utun1 'tcp[13] & 2 == 2'
```

Let's see what happens to octet 13 when a TCP datagram with `SYN-ACK` set arrives:

```
|C|E|U|A|P|R|S|F|
|---------------|
|0 0 0 1 0 0 1 0|
|---------------|
|7|6|5|4|3|2|1|0|
```

Now bits 1 and 4 are set in the 13th octet. The binary value of octet 13 is `00010010`

which translates to decimal:

$$
0*2^7 + 0*2^6 + 0*2^5 + 1*2^4 + 0*2^3 + 0*2^2 + 1*2^1 + 0*2^0 = 18
$$

Now we can't just use `tcp[13] == 18` in the tcpdump filter expression, because that would select only those packets that have `SYN-ACK` set, but not those with only `SYN` set. Remember that we don't care if `ACK` or any other control bit is set as long as `SYN` is set.

In order to achieve our goal, we need to logically AND the binary value of octet 13 with some other value to preserve the `SYN` bit. We know that we want `SYN` to be set in any case, so we'll logically AND the value in the 13th octet with the binary value of a `SYN`.

```
00010010 SYN-ACK 00000010 SYN
AND 00000010 (we want SYN) AND 00000010 (we want SYN)
-----------------------------------------------------
= 00000010 = 00000010
```

We see that this `AND` operation delivers the same result regardless whether `ACK` or another TCP control bit is set. The decimal representation of the `AND` value as well as the result of this operation is 2 (binary `00000010`), so we know that for packets with `SYN` set the following relation must hold true:

```
((value of octet 13) AND (2)) == (2)
```

This points us to the tcpdump filter expression: `tcpdump -i xl0 'tcp[13] & 2 == 2'`

Some offsets and field values may be expressed as names rather than as numeric values. For example `tcp[13]` may be replaced with `tcp[tcpflags]`. The following TCP flag field values are also available: `tcp-fin`, `tcp-syn`, `tcp-rst`, `tcp-push`, `tcp-act`, `tcp-urg`.

This can be demonstrated as:

```
tcpdump -i xl0 'tcp[tcpflags] & tcp-push != 0'
```

Note that you should use single quotes or a backslash in the expression to hide the `AND` (`&`) special character from the shell.

Tcpdump provides several options that enhance or modify its output. The following are the commonly used options for tcpdump command.

| Option              | Description                                                                                                                     |
| :------------------ | :------------------------------------------------------------------------------------------------------------------------------ |
| `-i`                | Listen on the specified interface.                                                                                              |
| `-n`                | Don't resolve hostnames. You can use `-nn` to don't resolve hostnames or port names.                                            |
| `-t`                | Print human-readable timestamp on each dump line, `-tttt`: Give maximally human-readable timestamp output.                      |
| `-X`                | Show the packet's contents in both hex and ascii.                                                                               |
| `-v`, `-vv`, `-vvv` | enables verbose logging/details (which among other things will give us a running total on how many packets are captured)        |
| `-c` N              | Only get N number of packets and then stop.                                                                                     |
| `-s`                | Define the snaplength (size) of the capture in bytes. Use `-s0` to get everything, unless you are intentionally capturing less. |
| `-S`                | Print absolute sequence numbers.                                                                                                |
| `-q`                | Show less protocol information.                                                                                                 |
| `-w`                | Write the raw packets to file                                                                                                   |
| `-C file_size(M)`   | tells tcpdump to store up to x MB of packet data per file.                                                                      |
| `-G rotate_seconds` | Create a new file every time the specified number of seconds has elapsed.                                                       |

## USAGE

```bash
# Basic communication // see the basics without many options
tcpdump -nS

# Basic communication (very verbose) // see a good amount of traffic, with verbosity and no name help
tcpdump -nnvvS

# A deeper look at the traffic // adds -X for payload but doesn't grab any more of the packet
tcpdump -nnvvXS

# Heavy packet viewing // the final “s” increases the snaplength, grabbing the whole packet
tcpdump -nnvvXSs 1514

# host // look for traffic based on IP address (also works with hostname if you're not using -n)
tcpdump host 1.2.3.4

# src, dst // find traffic from only a source or destination (eliminates one side of a host conversation)
tcpdump src 2.3.4.5
tcpdump dst 3.4.5.6

# net // capture an entire network using CIDR notation
tcpdump net 1.2.3.0/24

# proto // works for tcp, udp, and icmp. Note that you don't have to type proto
tcpdump icmp

# port // see only traffic to or from a certain port
tcpdump port 3389

# src, dst port // filter based on the source or destination port
tcpdump src port 1025 # tcpdump dst port 389

# src/dst, port, protocol // combine all three
tcpdump src port 1025 and tcp
tcpdump udp and src port 53

# You also have the option to filter by a range of ports instead of declaring them individually, and to only see packets that are above or below a certain size.

# Port Ranges // see traffic to any port in a range
tcpdump portrange 21-23

# Packet Size Filter // only see packets below or above a certain size (in bytes)
tcpdump less 32
tcpdump greater 128
# [ You can use the symbols for less than, greater than, and less than or equal / greater than or equal signs as well. ]

# // filtering for size using symbols
tcpdump > 32
tcpdump <= 128

# [ Note: Only the PSH, RST, SYN, and FIN flags are displayed in tcpdump's flag field output. URGs and ACKs are displayed, but they are shown elsewhere in the output rather than in the flags field ]

# Keep in mind the reasons these filters work. The filters above find these various packets because tcp[13] looks at offset 13 in the TCP header, the number represents the location within the byte, and the !=0 means that the flag in question is set to 1, i.e. it's on.

# Show all URG packets:
tcpdump 'tcp[13] & 32 != 0'

# Show all ACK packets:
tcpdump 'tcp[13] & 16 != 0'

# Show all PSH packets:
tcpdump 'tcp[13] & 8 != 0'

# Show all RST packets:
tcpdump 'tcp[13] & 4 != 0'

# Show all SYN packets:
tcpdump 'tcp[13] & 2 != 0'

# Show all FIN packets:
tcpdump 'tcp[13] & 1 != 0'

# Show all SYN-ACK packets:
tcpdump 'tcp[13] = 18'

# Show icmp echo request and reply
tcpdump -n icmp and 'icmp[0] != 8 and icmp[0] != 0'

# Show all IP packets with a non-zero TOS field (one byte TOS field is at offset 1 in IP header):
tcpdump -v -n ip and ip[1]!=0

# Show all IP packets with TTL less than some value (on byte TTL field is at offset 8 in IP header):
tcpdump -v ip and 'ip[8]<2'

# Show TCP SYN packets:
tcpdump -n tcp and port 80 and 'tcp[tcpflags] & tcp-syn == tcp-syn'
tcpdump tcp and port 80 and 'tcp[tcpflags] == tcp-syn'
tcpdump -i <interface> "tcp[tcpflags] & (tcp-syn) != 0"

# Show TCP ACK packets:
tcpdump -i <interface> "tcp[tcpflags] & (tcp-ack) != 0"

# Show TCP SYN/ACK packets (typically, responses from servers):
tcpdump -n tcp and 'tcp[tcpflags] & (tcp-syn|tcp-ack) == (tcp-syn|tcp-ack)'
tcpdump -n tcp and 'tcp[tcpflags] & tcp-syn == tcp-syn' and 'tcp[tcpflags] & tcp-ack == tcp-ack'
tcpdump -i <interface> "tcp[tcpflags] & (tcp-syn|tcp-ack) != 0"

# Show TCP FIN packets:
tcpdump -i <interface> "tcp[tcpflags] & (tcp-fin) != 0"

# Show ARP Packets with MAC address
tcpdump -vv -e -nn ether proto 0x0806

# Show packets of a specified length (IP packet length (16 bits) is located at offset 2 in IP header):
tcpdump -l icmp and '(ip[2:2]>50)' -w - |tcpdump -r - -v ip and '(ip[2:2]<60)'
```
