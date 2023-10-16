<!-- from: https://showmethepackets.com/index.php/2021/09/05/tshark-working-with-statistics/ -->

By Securitynik on 2021-09-05 11:58:24

To see the statistics available, we leverage _tshark -z help_: Below shows a snapshot of this output.

```console
$ tshark -z help
tshark: The available statistics for the "-z" option are:
...
     conv,eth
     conv,fc
     conv,fddi
     conv,ip
     conv,ipv6
     conv,ipx
     conv,jxta
     conv,mptcp
     conv,ncp
     conv,rsvp
     conv,sctp
     conv,sll
     conv,tcp
     conv,tr
     conv,udp
...
```

When analyzing a PCAP, it is highly likely, you will look at the _Protocol Hierarchy_, let's do that.

```console
$ tshark -n -r hydra_port_445.pcap -q -z io,phs
===================================================================
Protocol Hierarchy Statistics
Filter:

sll                                      frames:11337 bytes:1289873
  ip                                     frames:11337 bytes:1289873
    tcp                                  frames:11337 bytes:1289873
      nbss                               frames:3925 bytes:767089
        smb                              frames:3925 bytes:767089
      vssmonitoring                      frames:14 bytes:868
===================================================================
```

Looking at endpoints in a PCAP file, always helps to give visibility into the hosts seen on your network and how they were communicating, as it relates to bytes and packets.

```console
$ tshark -n -r hydra_port_445.pcap -q -z endpoints,ip
================================================================================
IPv4 Endpoints
Filter:<No Filter>
                       |  Packets  | |  Bytes  | | Tx Packets | | Tx Bytes | | Rx Packets | | Rx Bytes |
10.0.0.102                 11337       1289873       6866          812766        4471          477107
10.0.0.104                  4491        514851       1755          191201        2736          323650
10.0.0.106                  4445        510943       1709          187293        2736          323650
10.0.0.105                  2246        246142        938           91528        1308          154614
10.0.0.90                    150         17425         67            6955          83           10470
10.0.0.103                     5           512          2             130           3             382
================================================================================
```

Similarly, we can look at the TCP Endpoints.

```console
$ tshark -n -r hydra_port_445.pcap -q -z endpoints,tcp | more
================================================================================
TCP Endpoints
Filter:<No Filter>
                       |  Port  ||  Packets  | |  Bytes  | | Tx Packets | | Tx Bytes | | Rx Packets | | Rx Bytes |
10.0.0.104                  445       4491        514851       1755          191201        2736          323650
10.0.0.106                  445       4445        510943       1709          187293        2736          323650
10.0.0.105                  445       2246        246142        938           91528        1308          154614
10.0.0.90                   445        150         17425         67            6955          83           10470
10.0.0.102                57662         13          1420          7             828           6             592
10.0.0.102                52916         13          1400          7             844           6             556
10.0.0.102                52936         13          1400          7             844           6             556
...
```

TCP (and similarly UDP) endpoints is helpful. As you see above, you also have the bytes and packets exchanged on the port the host was using at a particular point in time. For example, you see three different ports being reported for the endpoint at IP 10.0.0.102.

While endpoint information is helpful, you may instead wish to see conversations occurring between endpoints. Looking at Ethernet conversations is helpful to see hosts communicating on the local LAN. Maybe helpful to identify lateral movement. Most days, your internals hosts will be communicating with servers local to its' subnet or its router (default gateway). When there are many Ethernet addresses communicating which are not server or default gateway related, this may be a cause of concern.

```console
$ tshark -n -r securitynik_kaieteur_falls.pcap -q -z conv,eth
================================================================================
Ethernet Conversations
Filter:<No Filter>
                                               |       <-      | |       ->      | |     Total     |    Relative    |   Duration   |
                                               | Frames  Bytes | | Frames  Bytes | | Frames  Bytes |      Start     |              |
00:22:19:01:ef:0d    <-> cc:b0:da:ba:42:39         39 2,532bytes      78 112kB         117 114kB         0.000000000        27.1526
================================================================================
```

Above shows good insights into two MAC addresses communicating on the LAN.

Moving to IP conversations.

```console
$ tshark -n -r securitynik_kaieteur_falls.pcap -q -z conv,ip
================================================================================
IPv4 Conversations
Filter:<No Filter>
                                               |       <-      | |       ->      | |     Total     |    Relative    |   Duration   |
                                               | Frames  Bytes | | Frames  Bytes | | Frames  Bytes |      Start     |              |
146.66.65.213        <-> 192.168.0.26              37 2,424bytes      76 112kB         113 114kB        26.904525000        0.2481
72.21.91.29          <-> 192.168.0.26               2 108bytes        2 120bytes        4 228bytes      0.000000000         0.0019
================================================================================
```

We now have better insights into the IP communication. As expected with the conversations we have information on the frames, bytes, duration, etc.

Digging a bit deeper ...

```console
$ tshark -n -r securitynik_kaieteur_falls.pcap -q -z conv,tcp
================================================================================
TCP Conversations
Filter:<No Filter>
                                                           |       <-      | |       ->      | |     Total     |    Relative    |   Duration   |
                                                           | Frames  Bytes | | Frames  Bytes | | Frames  Bytes |      Start     |              |
192.168.0.26:50237         <-> 146.66.65.213:80                76 112kB          37 2,424bytes     113 114kB        26.904525000         0.2481
192.168.0.26:50230         <-> 72.21.91.29:80                   2 120bytes        2 108bytes        4 228bytes      0.000000000         0.0019
================================================================================
```

Now we have a more intimate view of the communications. We are able to see fully the session as it relates to the IP addresses and ports the communications occurred on. More importantly, you can see the frames, bytes, duration, etc.

Now that we know there is HTTP communication occurring above, let's grab some HTTP statistics.

```console
$ tshark -n -r securitynik_kaieteur_falls.pcap -q -z http,stat
===================================================================
HTTP Statistics
* HTTP Status Codes in reply packets
    HTTP 200 OK
* List of HTTP Request methods
          GET 1
===================================================================
```

Above, we see information on the HTTP status code and the request method. Looks like only 1 request method was found in the PCAP.

This can further be confirmed by extracting the _http.request.method_ field

```console
$ tshark -n -r securitynik_kaieteur_falls.pcap -q -T fields -e http.request.method | sort | uniq
GET
```

Moving on with other HTTP statistics, looking at the request tree

```console
$ tshark -n -r securitynik_kaieteur_falls.pcap -q -z http_req,tree
=================================================================================================================================================================
HTTP/Requests:
Topic / Item                                      Count         Average       Min Val       Max Val       Rate (ms)     Percent       Burst Rate    Burst Start
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
HTTP Requests by HTTP Host                        1                                                       0.0041        100%          0.0100        26.912
 worldtoptop.com                                  1                                                       0.0041        100.00%       0.0100        26.912
  /wp-content/uploads/2011/05/kaieteur_falls.jpg  1                                                       0.0041        100.00%       0.0100        26.912

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
```

Above we see a request was made to _worldtop.com_ for a file _kaieteur_falls.jpg_. Looking to the server tree ...

```console
$ tshark -n -r securitynik_kaieteur_falls.pcap -q -z http_srv,tree
=================================================================================================================================================
HTTP/Load Distribution:
Topic / Item                      Count         Average       Min Val       Max Val       Rate (ms)     Percent       Burst Rate    Burst Start
-------------------------------------------------------------------------------------------------------------------------------------------------
HTTP Requests by Server           1                                                       0.0041        100%          0.0100        26.912
 HTTP Requests by Server Address  1                                                       0.0041        100.00%       0.0100        26.912
  146.66.65.213                   1                                                       0.0041        100.00%       0.0100        26.912
   worldtoptop.com                1                                                       0.0041        100.00%       0.0100        26.912
 HTTP Requests by HTTP Host       1                                                       0.0041        100.00%       0.0100        26.912
  worldtoptop.com                 1                                                       0.0041        100.00%       0.0100        26.912
   146.66.65.213                  1                                                       0.0041        100.00%       0.0100        26.912
HTTP Responses by Server Address  1                                                       0.0041        100%          0.0100        27.153
 146.66.65.213                    1                                                       0.0041        100.00%       0.0100        27.153
  OK                              1                                                       0.0041        100.00%       0.0100        27.153

-------------------------------------------------------------------------------------------------------------------------------------------------
```

Above shows request by server address, hostname and then ultimately the server response. So we are confident that the request made to this server was returned successfully.

To extract the file "kaieteur_falls.jpg" file, we do the following:

```console
# 1
$ tshark -n -r securitynik_kaieteur_falls.pcap -q --export-objects http,/tmp/

# 2
$ ls -al /tmp/kaieteur_falls.jpg
-rw-r--r-- 1 root root 107720 Aug 18 22:52 /tmp/kaieteur_falls.jpg

# 3
$ xdg-open /tmp/kaieteur_falls.jpg &
```

At 1 above, we exported content from HTTP. In 2 we performed _ls_ on the file to verify its existence. Finally in 3, we opened the file using _xdg-open_. This is what the file looks like.

The above image is that of the Kaieteur Falls in Guyana South America. It is considered to be the largest single drop water falls in the world. Go for a visit when you get a chance if you are a nature lover.

Now that we've look at HTTP, let's transition look at _io,stat_. Specifically, let's look at traffic from the perspective of two minutes intervals.

```console
$ tshark -n -r MS17_010\ -\ exploit.pcap -q -z io,stat,120
==================================
| IO Statistics                  |
|                                |
| Duration: 1359.431051 secs     |
| Interval:  120 secs            |
|                                |
| Col 1: Frames and bytes        |
|--------------------------------|
|              |1                |
| Interval     | Frames |  Bytes |
|--------------------------------|
|    0 <>  120 |   1074 | 845196 |
|  120 <>  240 |      6 |    912 |
|  240 <>  360 |     11 |   2058 |
|  360 <>  480 |     11 |   2042 |
|  480 <>  600 |     27 |  10644 |
|  600 <>  720 |     13 |   2524 |
|  720 <>  840 |      6 |    912 |
|  840 <>  960 |      6 |    912 |
|  960 <> 1080 |     11 |   1930 |
| 1080 <> 1200 |     15 |   2686 |
| 1200 <> 1320 |      6 |    912 |
| 1320 <> Dur  |    123 |  95666 |
==================================
```

As we look above, we see a pattern of 6 frames and 912 bytes at 4 different two minute intervals.

```console
$ tshark -n -r MS17_010\ -\ exploit.pcap -q -z io,stat,120,"MAX(frame.time_relative)frame.time_relative",ip.addr==10.0.0.90,"MIN(frame.time_relative)frame.time_relative" -t ad
=====================================================================
| IO Statistics                                                     |
|                                                                   |
| Duration: 1359.431051 secs                                        |
| Interval:  120 secs                                               |
|                                                                   |
| Col 1: MAX(frame.time_relative)frame.time_relative                |
|     2: ip.addr==10.0.0.90                                         |
|     3: MIN(frame.time_relative)frame.time_relative                |
|-------------------------------------------------------------------|
|                     |1            |2                |3            |
| Date and time       |     MAX     | Frames |  Bytes |     MIN     |
|-------------------------------------------------------------------|
| 2018-02-24 22:20:15 |   85.649770 |   1074 | 845196 |    0.000000 |
| 2018-02-24 22:22:15 |  206.367818 |      6 |    912 |  145.984684 |
| 2018-02-24 22:24:15 |  327.462658 |     11 |   2058 |  266.594469 |
| 2018-02-24 22:26:15 |  467.993210 |     11 |   2042 |  387.750787 |
| 2018-02-24 22:28:15 |  596.869106 |     27 |  10644 |  528.390247 |
| 2018-02-24 22:30:15 |  699.492896 |     13 |   2524 |  618.804501 |
| 2018-02-24 22:32:15 |  820.258716 |      6 |    912 |  759.858036 |
| 2018-02-24 22:34:15 |  941.086732 |      6 |    912 |  880.615586 |
| 2018-02-24 22:36:15 | 1070.588021 |     11 |   1930 | 1001.436265 |
| 2018-02-24 22:38:15 | 1187.508831 |     15 |   2686 | 1130.896538 |
| 2018-02-24 22:40:15 | 1308.274574 |      6 |    912 | 1247.825192 |
| 2018-02-24 22:42:15 | 1359.431051 |    123 |  95666 | 1351.488699 |
=====================================================================
```

Above we expand the _io,stat_ grabbing additional information of a particular IP.

Finally, if you wanted to gain insights into the SMB commands seen in the PCAP, you can use _smb,srt_.

```console
$ tshark -n -r MS17_010\ -\ exploit.pcap -q -z smb,srt
===================================================================
SMB SRT Statistics:
Filter: smb.cmd
Index  Commands               Calls    Min SRT    Max SRT    Avg SRT    Sum SRT
   43  Echo                        2   0.000072   0.000087   0.000080   0.000159
   50  Trans2                      2  10.136100  10.242747  10.189424  20.378847
  115  Session Setup AndX          4   0.000081   0.000117   0.000099   0.000396
  117  Tree Connect AndX           2   0.000103   0.000110   0.000107   0.000213

Filter: smb.trans2.cmd
Index  Transaction2 Commands  Calls    Min SRT    Max SRT    Avg SRT    Sum SRT

Filter: smb.nt.function
Index  NT Transaction Sub-Commands Calls    Min SRT    Max SRT    Avg SRT    Sum SRT
    0  <unknown>                   2   0.000087   0.000154   0.000121   0.000241
==================================================================
```

Ok! That's it for this post. There are many more statistics for you to take advantage of, depending on the protocols you are using. Have fun exploring!

References:  
[tshark - The Wireshark Network Analyzer 3.4.7](https://www.wireshark.org/docs/man-pages/tshark.html)  
[All PCAPs can be found at my GitHub page](https://github.com/SecurityNik/SUWtHEh-)
