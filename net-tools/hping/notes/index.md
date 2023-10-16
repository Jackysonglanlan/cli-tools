<!-- from: https://itigic.com/hping3-create-tcp-ip-packets-and-perform-dos-attacks-on-linux -->

# Hping3: Create TCP / IP Packets and Perform DoS Attacks on Linux

When we want to check connectivity, we all use the Ping command, a tool that sends ICMP packets to a specific server to know if the communication is correct or there is a problem. However, this tool is very simple and does not allow practically any modification of the packets, nor does it use other protocols to send information. Hping3 is a more advanced application, which will allow us to modify the packets that are sent through the TCP / IP protocol, so that we can have a much greater control of these packets, being able to adapt them according to our needs.

## Main features <a id="main-features" ></a>

Hping3 is a terminal application for [Linux](https://itigic.com/tag/linux/) that will allow us to easily analyze and assemble TCP / IP packets. Unlike a conventional ping that is used to send ICMP packets, this application allows the sending of TCP, UDP and RAW-IP packets. Along with the analysis of packets, this application can also be used for other security purposes, for example, to test the effectiveness of a [firewall](https://itigic.com/tag/firewall/) through different protocols, the detection of suspicious or modified packets, and even protection against attacks. DoS of a system or a Firewall.

In the past, this tool is used for cybersecurity issues, but we can also use it to test networks and hosts. Some of the main applications that we can do with this tool are the following:

- Check the security and operation of the firewalls.
- Use it as an advanced port scan, although it is better to use Nmap for this task.
- Network tests using different protocols, ToS, fragmentation etc.
- Find out the MTU on the route manually.
- Advanced traceroute using all supported protocols
- Remote fingerprint from operating system
- Check the time away
- TCP / IP stack audit

Due to the large number of possibilities of this tool, in this article we are going to show you the main uses and how to do it.

## Install Hping3 <a id="install-hping3" ></a>

```console
$ sudo apt install hping3
```

The tool will occupy about 3,600 KB that, once installed, we can start using it.

## Examples of using Hping3 <a id="examples-of-using-hping3" ></a>

### Simple ping test <a id="simple-ping-test" ></a>

We can use this tool like the conventional ping command, obtaining practically the same results. To do this we simply have to type:

```console
$ hping3 www.google.es
```

And we will see how this simple connection test is performed. (We can change the Google domain to any other or directly use an IP to ping it).

### Plot connection path <a id="plot-connection-path" ></a>

In a similar way to the "tracert" option in [Windows](https://itigic.com/tag/windows/) or "traceroute" in Linux, with this tool we can also follow all the jumps between networks of a packet from when it leaves our computer until it reaches its destination, being able to know at any time if there is some kind of problem in the connection.

To do this we simply have to type:

```console
$ hping3 redeszone.net -t 1 --traceroute
```

### Port scanning using the TCP SYN flag <a id="port-scanning-using-the-tcp-syn-flag" ></a>

This tool also allows us to send packets under the TCP protocol, in the purest [Nmap](https://itigic.com/scan-ports-with-nmap-list-of-nmap-commands/) style. To perform a scan using this method, we will type in the terminal "hping3 --S [Destination IP] --p [Port]", the result being similar to the following:

```console
$ hping3 -S www.google.es --p 80
```

The result of this test will return an **SA** flag, which means that it corresponds to **SYN / ACK** , that is, the communication has been accepted, or what is the same, that **the port is open** . Otherwise, if the value is **RA it** corresponds to **RST / ACK** or what is the same, that the communication has not been carried out correctly because **the port is closed** or filtered.

In this way we will be able to know, for example, if communication is allowed to a certain port, or if otherwise the Firewall is filtering it.

### Sign packages with a custom text file <a id="sign-packages-with-a-custom-text-file" ></a>

It is possible to use this tool to modify the packages we send and insert a personalized message in them similar to a signature. To do this we simply have to type:

```console
$ hping3 redeszone.net -d 50 -E firmaredeszone.txt
```

This command will introduce into the Ping packages the content of the indicated txt file. If we analyze these packages with suitable software such as WireShark we would see that within them is the content of the file in question.

The entered parameters mean:

- -d: The length of the message that we are going to enter, in this case, 50.
- -E: File from which we are going to take the message signature that we want to introduce to the packages.

We can also use other parameters, for example, -p to indicate the port to which we want to send these packets or -2 to send the packets through the UDP protocol.

### Generate multiple requests to test DoS and DDoS protection <a id="generate-multiple-requests-to-test-dos-and-ddos-protection" ></a>

This tool will also allow us to check the stability of our system against network attacks such as DoS and DDoS, generating real tests, either towards localhost or towards another server inside (or outside) the network.

We can make a series of unique pings by modifying the source IP of the same in the TCP / IP packets simply by typing:

```console
$ hping3 --rand-source 192.168.1.1
```

Likewise, we can add the --flood parameter so that the packets are sent in real time in bulk. In this way, we will be able to check, firstly, if our firewall works and, secondly, how well our system responds to a threat of DDoS attack.

For this we will type:

```console
$ hping3 --rand-source --flood 192.168.1.1
```

In just a couple of seconds we have generated more than 25,000 packets, so we must be careful as our network may be blocked and unusable.

With this, a large number of packets with a "false origin" will begin to be generated (thanks to the rand-source parameter) that will be sent continuously to the destination server (in this case 192.168.1.1). In this way we can verify the robustness of our system against DDoS attacks since, if the system stops working or crashes, there may be a configuration failure and that we must apply the corresponding measures to prevent this from happening in a real environment.

This tool is very useful, although it should always be used in closed and controlled environments since going outside it is possible that we end up carrying out a denial of service attack on a team that we should not, this being illegal and may end up sanctioned for it.

We recommend that you **[access the official hping MAN PAGE**](http://linux.die.net/man/8/hping3) to find out all your options.

**ICMP type codes**

It is very useful to know some ICMP codes that hping3 could show us, below, you have all the most used ones:

| ICMP type                  | Description                                                               | Code    | Category  | Defined In               |
| :------------------------- | :------------------------------------------------------------------------ | :------ | :-------- | :----------------------- |
| 0                          | Echo Reply                                                                | 0       | Query     | [RFC792]                 |
| 1                          | Unassigned                                                                | NA      | Other     | NA                       |
| 2                          | Unassigned                                                                | NA      | Other     | NA                       |
| 3                          | Destination Unreachable                                                   | 0 - 15  | Error     | [RFC792]                 |
| 4                          | Source Quench (Deprecated)                                                | NA      | Error     | [RFC792][rfc6633]        |
| 5                          | Redirect                                                                  | 0 - 3   | Error     | [RFC792]                 |
| 6                          | Alternate Host Address (Deprecated)                                       | NA      | Other     | [RFC6918]                |
| 7                          | Unassigned                                                                | NA      | Other     | NA                       |
| 8                          | Echo                                                                      | 0       | Query     | [RFC792]                 |
| 9                          | Router Advertisement                                                      | 0       | Other     | [RFC1256]                |
| 10                         | Router Solicitation                                                       | 0       | Other     | [RFC1256]                |
| 11                         | Time Exceeded                                                             | 0 - 1   | Error     | [RFC792]                 |
| 12                         | Parameter Problem                                                         | 0 -2    | Error     | [RFC792]                 |
| 13                         | Timestamp                                                                 | 0       | Query     | [RFC792]                 |
| 14                         | Timestamp Reply                                                           | 0       | Query     | [RFC792]                 |
| 15                         | Information Request (Deprecated)                                          | 0       | Query     | [RFC792][rfc6918]        |
| 16                         | Information Reply (Deprecated)                                            | 0       | Query     | [RFC792][rfc6918]        |
| 17                         | Address Mask Request (Deprecated)                                         | 0       | Query     | [RFC950][rfc6918]        |
| 18                         | Address Mask Reply (Deprecated)                                           | 0       | Query     | [RFC950][rfc6918]        |
| 19                         | Reserved (for Security)                                                   | 0       | Other     | [Solo]                   |
| 20-29                      | Reserved (for Robustness Experiment)                                      | NA      | Other     | [ZSu]                    |
| 30                         | Traceroute (Deprecated)                                                   | NA      | Other     | [RFC1393][rfc6918]       |
| 31                         | Datagram Conversion Error (Deprecated)                                    | NA      | Other     | [RFC1475][rfc6918]       |
| 32                         | Mobile Host Redirect (Deprecated)                                         | NA      | Other     | [David_Johnson][rfc6918] |
| 33                         | IPv6 Where-Are-You (Deprecated)                                           | NA      | Other     | [Simpson][rfc6918]       |
| 34                         | IPv6 I-Am-Here (Deprecated)                                               | NA      | Other     | [Simpson][rfc6918]       |
| 35                         | Mobile Registration Request (Deprecated)                                  | NA      | Other     | [Simpson][rfc6918]       |
| 36                         | Mobile Registration Reply (Deprecated)                                    | NA      | Other     | [Simpson][rfc6918]       |
| 37                         | Domain Name Request (Deprecated)                                          | NA      | Query     | [RFC1788][rfc6918]       |
| 38                         | Domain Name Reply (Deprecated)                                            | NA      | Query     | [RFC1788][rfc6918]       |
| 39                         | SKIP (Deprecated)                                                         | NA      | Other     | [Markson][rfc6918]       |
| 40                         | Photuris                                                                  | 0 - 5   | Other     | [RFC2521]                |
| 41                         | ICMP messages utilized by experimental mobility protocols such as Seamoby | NA      | Other     | [RFC4065]                |
| 42                         | Extended Echo Request                                                     | 0 - 255 | Query     | [RFC8335]                |
| 43                         | Extended Echo Reply                                                       | 0 - 255 | Query     | [RFC8335]                |
| 44-252                     | Unassigned                                                                | NA      | Other     | 253                      |
| RFC3692-style Experiment 1 | NA                                                                        | Other   | [RFC4727] | 254                      |
| RFC3692-style Experiment 2 | NA                                                                        | Other   | [RFC4727] | 255                      |
| Reserved                   | NA                                                                        | Other   |           |                          |

**ICMP sub-type codes**

| ICMP message Type | Code (ICMP message sub-type) | Description                                                           |
| :---------------- | :--------------------------- | :-------------------------------------------------------------------- |
| 3                 | 0                            | Net Unreachable                                                       |
| 3                 | 1                            | Host Unreachable                                                      |
| 3                 | 2                            | Protocol Unreachable                                                  |
| 3                 | 3                            | Port Unreachable                                                      |
| 3                 | 4                            | Fragmentation Needed and Don't Fragment was Set                       |
| 3                 | 5                            | Source Route Failed                                                   |
| 3                 | 6                            | Destination Network Unknown                                           |
| 3                 | 7                            | Destination Host Unknown                                              |
| 3                 | 8                            | Source Host Isolated                                                  |
| 3                 | 9                            | Communication with Destination Network is Administratively Prohibited |
| 3                 | 10                           | Communication with Destination Host is Administratively Prohibited    |
| 3                 | 11                           | Destination Network Unreachable for Type of Service                   |
| 3                 | 12                           | Destination Host Unreachable for Type of Service                      |
| 3                 | 13                           | Communication Administratively Prohibited                             |
| 3                 | 14                           | Host Precedence Violation                                             |
| 3                 | 15                           | Precedence cutoff in effect                                           |
| 5                 | 0                            | Redirect Datagram for the Network (or subnet)                         |
| 5                 | 1                            | Redirect Datagram for the Host                                        |
| 5                 | 2                            | Redirect Datagram for the Type of Service and Network                 |
| 5                 | 3                            | Redirect Datagram for the Type of Service and Host                    |
| 9                 | 0                            | Normal router advertisement                                           |
| 11                | 0                            | Time to Live exceeded in Transit                                      |
| 11                | 1                            | Fragment Reassembly Time Exceeded                                     |
| 12                | 0                            | The Pointer indicates the error                                       |
| 12                | 1                            | Missing a Required Option                                             |
| 12                | 2                            | Bad Length                                                            |
| 40                | 0                            | Bad SPI                                                               |
| 40                | 1                            | Authentication Failed                                                 |
| 40                | 2                            | Decompression Failed                                                  |
| 40                | 3                            | Decryption Failed                                                     |
| 40                | 4                            | Need Authentication                                                   |
| 40                | 5                            | Need Authorization                                                    |
| 42                | 0                            | No Error                                                              |
| 42                | 1-255                        | Unassigned                                                            |
| 43                | 0                            | No Error                                                              |
| 43                | 1                            | Malformed Query                                                       |
| 43                | 2                            | No Such Interface                                                     |
| 43                | 3                            | No Such Table Entry                                                   |
| 43                | 4                            | Multiple Interfaces Satisfy Query                                     |
| 43                | 5-255                        | Unassigned                                                            |
