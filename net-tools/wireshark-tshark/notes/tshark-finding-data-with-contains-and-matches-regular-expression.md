<!-- from: https://showmethepackets.com/index.php/2021/08/18/tshark-finding-data-with-contains-and-matches-regular-expression/ -->

By Securitynik on 2021-08-18 11:31:23

Recently, I've been working with the [SANS Institute](https://www.sans.org/) on some Livestream sessions, promoting the [SEC503: Intrusion Detection In Depth](https://www.sans.org/cyber-security-courses/intrusion-detection-in-depth/) class. As a result, I produced some videos using TShark. In the first of those videos, we did an [intro to TShark by focusing on reconnaissance at the IP layer](https://www.youtube.com/watch?v=fu1USvVXQn4). In the second session, we focused on [reconnaissance at the transport layer and working with some common application protocols.](https://www.youtube.com/watch?v=c5bdiMFq2wI) In the 3rd session, we [extracted suspicious and malicious content ](https://www.youtube.com/watch?v=9GjJNInAGyo)from PCAPS.

In a session prior to these, I focused on [Full Packet Capturing with TShark for Continuous Monitoring & Threat Intel via IP, Domains, & URLS](https://www.youtube.com/watch?v=ikhKUylOJCw). While I did not do blog posts for those (and I wish I had thought about it before), I've chosen to do a blog post for the [TShark and working with regular expressions](https://www.youtube.com/watch?v=m7wHQsI_SgM),

Many times, when looking at packets or logs, I leverage "_grep --perl-regexp_". However, when looking at packets for patterns, sequence of bytes, etc., do we really need to leverage _grep_ or another external tool? Let's see.

In [session three](https://www.youtube.com/watch?v=9GjJNInAGyo) in which I exported suspicious and malicious content, I used the following for example to identify the name of the malicious file:

```console
$ tshark -n -r attack-trace.pcap -V | grep ssms.exe
0030  63 68 6f 20 67 65 74 20 73 73 6d 73 2e 65 78 65   cho get ssms.exe
0070  26 73 73 6d 73 2e 65 78 65 0d 0a                  &ssms.exe..
0000  73 73 6d 73 2e 65 78 65 0d 0a                     ssms.exe..
0000  52 45 54 52 20 73 73 6d 73 2e 65 78 65 0d 0a      RETR ssms.exe..
```

... and the following example to identify bytes within the suspicious file.

```console
$ xxd -groupsize 1 -u decode-as.pcap | grep '0A 25 25 45'
0192b620: 72 65 66 0A 32 38 34 30 32 38 32 34 0A 25 25 45  ref.28402824.%%E
```

Let's now see how TShark can help us out here. First let's leverage the "_contains_" display filter:

```console
$ tshark -n -r securitynik_regex.pcap -Y 'frame contains WWW.SecurityNik.com'
```

Oooops!! Looks like we are starting off on the wrong foot. No result was returned. Well the reason no result was returned, is because contains is case sensitive. Let's try this again.

```console
$ tshark -n -r securitynik_regex.pcap -Y 'frame contains www.securitynik.com' -x | more
0000  08 00 00 00 00 00 00 02 00 01 04 06 08 00 27 0e   ..............'.
0010  34 8d 00 00 45 00 00 ae 95 8e 40 00 40 06 e9 5e   4...E.....@.@..^
0020  0a 00 02 0f 8e fb 20 53 e1 cc 00 50 14 d2 bd 46   ...... S...P...F
0030  00 00 fa 02 50 18 fa f0 bb fd 00 00 47 45 54 20   ....P.......GET
0040  2f 32 30 31 38 2f 30 37 2f 68 6f 73 74 2d 62 61   /2018/07/host-ba
0050  73 65 64 2d 74 68 72 65 61 74 2d 68 75 6e 74 69   sed-threat-hunti
0060  6e 67 2d 77 69 74 68 2e 68 74 6d 6c 20 48 54 54   ng-with.html HTT
0070  50 2f 31 2e 31 0d 0a 48 6f 73 74 3a 20 77 77 77   P/1.1..Host: www
0080  2e 73 65 63 75 72 69 74 79 6e 69 6b 2e 63 6f 6d   .securitynik.com
0090  0d 0a 55 73 65 72 2d 41 67 65 6e 74 3a 20 53 65   ..User-Agent: Se
00a0  63 75 72 69 74 79 4e 69 6b 20 54 65 73 74 69 6e   curityNik Testin
00b0  67 0d 0a 41 63 63 65 70 74 3a 20 2a 2f 2a 0d 0a   g..Accept: */*..
00c0  0d 0a                                             ..
```

Much better! Important take away, is that contains is case sensitive.

In the previous example, we looked at contents from the frame level. Let's move up to the IP layer.

```console
$ tshark -n -r securitynik_regex.pcap -Y 'ip contains sans.org' -x | more
0000  08 00 00 00 00 00 00 02 00 01 04 06 08 00 27 0e   ..............'.
0010  34 8d a8 d6 45 00 00 7c 54 40 40 00 40 06 8d cf   4...E..|T@@.@...
0020  0a 00 02 0f 2d 3c 1f 22 a3 0a 00 50 68 1a f9 d1   ....-<."...Ph...
0030  00 0b b8 02 50 18 fa f0 58 db 00 00 47 45 54 20   ....P...X...GET
0040  2f 20 48 54 54 50 2f 31 2e 31 0d 0a 48 6f 73 74   / HTTP/1.1..Host
0050  3a 20 77 77 77 2e 73 61 6e 73 2e 6f 72 67 0d 0a   : www.sans.org..
0060  55 73 65 72 2d 41 67 65 6e 74 3a 20 53 65 63 75   User-Agent: Secu
0070  72 69 74 79 4e 69 6b 20 54 65 73 74 69 6e 67 0d   rityNik Testing.
0080  0a 41 63 63 65 70 74 3a 20 2a 2f 2a 0d 0a 0d 0a   .Accept: */*....
```

Making progress! Similarly, I look at the TCP layer

```console
$ tshark -n -r securitynik_regex.pcap -Y 'tcp contains siriuscom.com' -x | more
0000  08 00 00 00 00 00 00 02 00 01 04 06 08 00 27 0e   ..............'.
0010  34 8d e6 73 45 00 00 81 e1 00 40 00 40 06 ca c4   4..sE.....@.@...
0020  0a 00 02 0f d1 3b b1 67 c5 ba 00 50 af 30 ea 13   .....;.g...P.0..
0030  00 08 ca 02 50 18 fa f0 8f 25 00 00 47 45 54 20   ....P....%..GET
0040  2f 20 48 54 54 50 2f 31 2e 31 0d 0a 48 6f 73 74   / HTTP/1.1..Host
0050  3a 20 77 77 77 2e 73 69 72 69 75 73 63 6f 6d 2e   : www.siriuscom.
0060  63 6f 6d 0d 0a 55 73 65 72 2d 41 67 65 6e 74 3a   com..User-Agent:
0070  20 53 65 63 75 72 69 74 79 4e 69 6b 20 54 65 73    SecurityNik Tes
0080  74 69 6e 67 0d 0a 41 63 63 65 70 74 3a 20 2a 2f   ting..Accept: */
0090  2a 0d 0a 0d 0a                                    *....
```

And finally, let's look at the application layer.

```console
$ tshark -n -r securitynik_regex.pcap -Y 'http.host contains "www.siriuscom.com"' -x | more
0000  08 00 00 00 00 00 00 02 00 01 04 06 08 00 27 0e   ..............'.
0010  34 8d e6 73 45 00 00 81 e1 00 40 00 40 06 ca c4   4..sE.....@.@...
0020  0a 00 02 0f d1 3b b1 67 c5 ba 00 50 af 30 ea 13   .....;.g...P.0..
0030  00 08 ca 02 50 18 fa f0 8f 25 00 00 47 45 54 20   ....P....%..GET
0040  2f 20 48 54 54 50 2f 31 2e 31 0d 0a 48 6f 73 74   / HTTP/1.1..Host
0050  3a 20 77 77 77 2e 73 69 72 69 75 73 63 6f 6d 2e   : www.siriuscom.
0060  63 6f 6d 0d 0a 55 73 65 72 2d 41 67 65 6e 74 3a   com..User-Agent:
0070  20 53 65 63 75 72 69 74 79 4e 69 6b 20 54 65 73    SecurityNik Tes
0080  74 69 6e 67 0d 0a 41 63 63 65 70 74 3a 20 2a 2f   ting..Accept: */
0090  2a 0d 0a 0d 0a                                    *....
```

Contains is a really a hex filter. If there is no colon after the first byte, the input is considered as ASCII.

Let's see some different ways we can detect "sans".

A similar (not the same) display filter may look like: 'dns.qry.name == "www.sans.org"'. Do note, I say similar because the first one is not fully _www.sans.org_ but just the string _sans_.

First up, using hex escaped characters.

```console
$ tshark -n -r securitynik_regex.pcap -Y 'dns.qry.name contains "\x73\x61\x6e\x73"' -x | more
0000  08 00 00 00 00 00 00 02 00 01 04 06 08 00 27 0e   ..............'.
0010  34 8d 00 00 45 00 00 3a e9 8a 40 00 40 11 05 0c   4...E..:..@.@...
0020  0a 00 02 0f 40 47 ff c6 e1 93 00 35 00 26 4c 54   ....@G.....5.&LT
0030  da 6f 01 00 00 01 00 00 00 00 00 00 03 77 77 77   .o...........www
0040  04 73 61 6e 73 03 6f 72 67 00 00 01 00 01         .sans.org.....
```

Next up, using a combination of ASCII and hex escaped characters.

```console
$ tshark -n -r securitynik_regex.pcap -Y 'dns.qry.name contains "www.\x73\x61\x6e\x73.org"' -x | more
0000  08 00 00 00 00 00 00 02 00 01 04 06 08 00 27 0e   ..............'.
0010  34 8d 00 00 45 00 00 3a e9 8a 40 00 40 11 05 0c   4...E..:..@.@...
0020  0a 00 02 0f 40 47 ff c6 e1 93 00 35 00 26 4c 54   ....@G.....5.&LT
0030  da 6f 01 00 00 01 00 00 00 00 00 00 03 77 77 77   .o...........www
0040  04 73 61 6e 73 03 6f 72 67 00 00 01 00 01         .sans.org.....
```

Finally, looking at the bytes separated by colons

```console
$ tshark -n -r securitynik_regex.pcap -Y 'dns.qry.name contains 73:61:6e:73' -x | more
0000  08 00 00 00 00 00 00 02 00 01 04 06 08 00 27 0e   ..............'.
0010  34 8d 00 00 45 00 00 3a e9 8a 40 00 40 11 05 0c   4...E..:..@.@...
0020  0a 00 02 0f 40 47 ff c6 e1 93 00 35 00 26 4c 54   ....@G.....5.&LT
0030  da 6f 01 00 00 01 00 00 00 00 00 00 03 77 77 77   .o...........www
0040  04 73 61 6e 73 03 6f 72 67 00 00 01 00 01         .sans.org.....
```

#### Regular expression using matches

When using matches, the filter expression is processed twice. Once by the Wireshark display filter engine and the second by PCRE library

Because of above, you are better of using `\\.` rather than `\.` when using matches for the dot/period.

While contains is good for finding a particular string, what about if you want to find a particular pattern. This is where matches is helpful. To see the power of matches, let's look at it first through the lens of "_contains_".

```console
$ tshark -n -r securitynik_regex.pcap -Y '(http.request.method contains GET) || (http.request.method contains POST)' | more
   13   5.134106    10.0.2.15 → 142.251.32.83 HTTP 194 GET /2018/07/host-based-threat-hunting-with.html HTTP/1.1
  344  47.459625    10.0.2.15 → 142.251.41.83 HTTP 194 GET /2018/07/understanding-ip-fragmentation.html HTTP/1.1
  634  64.722770    10.0.2.15 → 209.59.177.103 HTTP 149 GET / HTTP/1.1
  722  84.262193    10.0.2.15 → 45.60.31.34  HTTP 144 GET / HTTP/1.1
  809 163.016781    10.0.2.15 → 45.60.31.34  HTTP 145 POST / HTTP/1.1
  861 174.261670    10.0.2.15 → 209.59.177.103 HTTP 150 POST / HTTP/1.1
  917 186.636330    10.0.2.15 → 142.251.33.179 HTTP 195 POST /2018/07/understanding-ip-fragmentation.html HTTP/1.1
  933 200.366293    10.0.2.15 → 172.217.165.19 HTTP 195 POST /2018/07/host-based-threat-hunting-with.html HTTP/1.1
```

As can be seen above, contains was able to help us find the match. However, it took a little bit more bytes. A little bit more typing. Let's see what _matches_.

```console
$ tshark -n -r securitynik_regex.pcap -Y 'http.request.method matches "(GET|POST)"' | more
   13   5.134106    10.0.2.15 → 142.251.32.83 HTTP 194 GET /2018/07/host-based-threat-hunting-with.html HTTP/1.1
  344  47.459625    10.0.2.15 → 142.251.41.83 HTTP 194 GET /2018/07/understanding-ip-fragmentation.html HTTP/1.1
  634  64.722770    10.0.2.15 → 209.59.177.103 HTTP 149 GET / HTTP/1.1
  722  84.262193    10.0.2.15 → 45.60.31.34  HTTP 144 GET / HTTP/1.1
  809 163.016781    10.0.2.15 → 45.60.31.34  HTTP 145 POST / HTTP/1.1
  861 174.261670    10.0.2.15 → 209.59.177.103 HTTP 150 POST / HTTP/1.1
  917 186.636330    10.0.2.15 → 142.251.33.179 HTTP 195 POST /2018/07/understanding-ip-fragmentation.html HTTP/1.1
  933 200.366293    10.0.2.15 → 172.217.165.19 HTTP 195 POST /2018/07/host-based-threat-hunting-with.html HTTP/1.1
```

As can been seen above, matches have allowed us to simplify the process using regular expression. Above, we simply looked for _GET_ or _POST_. That was easy!

If you remember from above, contains is case sensitive. Matches, is however case insensitive.

```console
$ tshark -n -r securitynik_regex.pcap -Y 'http.request.method matches "(get|post)"'
   13   5.134106    10.0.2.15 → 142.251.32.83 HTTP 194 GET /2018/07/host-based-threat-hunting-with.html HTTP/1.1
  344  47.459625    10.0.2.15 → 142.251.41.83 HTTP 194 GET /2018/07/understanding-ip-fragmentation.html HTTP/1.1
  634  64.722770    10.0.2.15 → 209.59.177.103 HTTP 149 GET / HTTP/1.1
  722  84.262193    10.0.2.15 → 45.60.31.34  HTTP 144 GET / HTTP/1.1
  809 163.016781    10.0.2.15 → 45.60.31.34  HTTP 145 POST / HTTP/1.1
  861 174.261670    10.0.2.15 → 209.59.177.103 HTTP 150 POST / HTTP/1.1
  917 186.636330    10.0.2.15 → 142.251.33.179 HTTP 195 POST /2018/07/understanding-ip-fragmentation.html HTTP/1.1
  933 200.366293    10.0.2.15 → 172.217.165.19 HTTP 195 POST /2018/07/host-based-threat-hunting-with.html HTTP/1.1
```

As seen above, even though get and post are in lowercase, we still got results returned. This is unlike what was experienced with _contains_.

If we wanted to enforce the case sensitivity, we can use (?-i). We know from the previous command that both _GET_ and _POST_ methods are in this PCAP and in uppercase. Let's look for uppercase _GET_ and lowercase _POST_. Remember we are showing how to handle case sensitivity not insensitivity.

```console
$ tshark -n -r securitynik_regex.pcap -Y 'http.request.method matches "(?-i)(GET|post)"'
   13   5.134106    10.0.2.15 → 142.251.32.83 HTTP 194 GET /2018/07/host-based-threat-hunting-with.html HTTP/1.1
  344  47.459625    10.0.2.15 → 142.251.41.83 HTTP 194 GET /2018/07/understanding-ip-fragmentation.html HTTP/1.1
  634  64.722770    10.0.2.15 → 209.59.177.103 HTTP 149 GET / HTTP/1.1
  722  84.262193    10.0.2.15 → 45.60.31.34  HTTP 144 GET / HTTP/1.1
```

From the results returned, we can see only _GET_ and not post. This is because we enforced case sensitivity as in we asked for GET in uppercase and POST in lowercase

Let's now see if there is any other method other than GET or POST.

```console
$ tshark -n -r securitynik_regex.pcap -Y 'http.request.method matches "[^(get|post)]"'
```

No results were returned. This suggests there are no other HTTP methods in the file. Let's confirm that our command is working as expected and that this is not a false negative situation. To confirm this actually works, let's remove the "_post_". If it works, we should see post as we are negating the get.

```console
$ tshark -n -r securitynik_regex.pcap -Y 'http.request.method matches "[^(get)]"'
  809 163.016781    10.0.2.15 → 45.60.31.34  HTTP 145 POST / HTTP/1.1
  861 174.261670    10.0.2.15 → 209.59.177.103 HTTP 150 POST / HTTP/1.1
  917 186.636330    10.0.2.15 → 142.251.33.179 HTTP 195 POST /2018/07/understanding-ip-fragmentation.html HTTP/1.1
  933 200.366293    10.0.2.15 → 172.217.165.19 HTTP 195 POST /2018/07/host-based-threat-hunting-with.html HTTP/1.1
```

Good stuff! We have results so we know our filter is correct. Sometimes, you need to find other ways to validate your command works.

There might be times when you know the first or first few and probably the last or last few letters. Matches can help here too! Let's say we are aware of a DNS request or response starting and ending with "s", has 2 characters in the middle but you not sure what those characters are. We can use the following:

```console
$ tshark -n -r securitynik_regex.pcap -Y 'dns matches "s..s"'
  715  84.199441    10.0.2.15 → 64.71.255.198 DNS 78 Standard query 0xda6f A www.sans.org
  716  84.199465    10.0.2.15 → 64.71.255.198 DNS 78 Standard query 0x686d AAAA www.sans.org
  717  84.222652 64.71.255.198 → 10.0.2.15    DNS 165 Standard query response 0x686d AAAA www.sans.org SOA ns-1746.awsdns-26.co.uk
```

What about those times when it has x or more characters in the middle? Below it has 5 or more characters

```console
$ tshark -n -r securitynik_regex.pcap -Y 'dns matches "sec.{5,}com"'
    3   0.000235    10.0.2.15 → 64.71.255.198 DNS 85 Standard query 0x4872 A www.securitynik.com
    4   0.000241    10.0.2.15 → 64.71.255.198 DNS 85 Standard query 0x0d7d AAAA www.securitynik.com
    5   0.150729 64.71.255.198 → 10.0.2.15    DNS 166 Standard query response 0x4872 A www.securitynik.com CNAME www.securitynik.com.ghs.googlehosted.com CNAME ghs.googlehosted.com A 172.217.165.19
```

Similarly, we can say we would only like to see results where there is a minimum of 1 or a maximum of 3 characters after the s:

```console
$ tshark -n -r securitynik_regex.pcap -Y 'dns matches "s.{1,3}\.org"'
  715  84.199441    10.0.2.15 → 64.71.255.198 DNS 78 Standard query 0xda6f A www.sans.org
  716  84.199465    10.0.2.15 → 64.71.255.198 DNS 78 Standard query 0x686d AAAA www.sans.org
  717  84.222652 64.71.255.198 → 10.0.2.15    DNS 165 Standard query response 0x686d AAAA www.sans.org SOA ns-1746.awsdns-26.co.uk
```

Let's say, we have a PCAP file with the following IP addresses:

```console
$ tshark -n -r securitynik_regex.pcap  -T fields -e ip.src | sort | uniq
10.0.2.15
10.0.2.2
142.251.32.83
142.251.33.179
142.251.41.83
172.217.1.19
172.217.165.19
209.59.177.103
45.60.31.34
64.71.255.198
```

What we need to do now, is to extract the IPs where octet 1 starts with 142. Octet 2 only contains the number 1, 2 or 5 and up to 3 numbers. Octet 3 can only be 32 or 33. Octet 4 can only have be 3 numbers anywhere between 0 and 9.

Let's say we to look for source IPs that match a particular pattern. In this case let's just say 142.

```console
$ tshark -n -r securitynik_regex.pcap -Y 'ip.src matches "142"' | more
tshark: ip.src (type=IPv4 address) cannot participate in 'matches' comparison.
```

Ooops! Looks like we got an error about type mismatch. Let's convert this IPv4 address type field to a string and build out our filter at the same time. Our filter will look for a source IP address which starts with 142 in the first octet. The second octet should only consist of the number 1, 2 or 5. The third octet has to be either the number 32 or 33 and the final octet can be any 3 digit number between 0 and 9.

```console
$ tshark -n -r securitynik_regex.pcap -Y 'string(ip.src) matches "^142\\.[1,2,5]{1,3}\\.(32|33)\\.[0-9]{3}"' -T fields -e ip.src | sort | uniq
142.251.33.179
```

A little bit more detail of the same filter.

```console
$ tshark -n -r securitynik_regex.pcap -Y 'string(ip.src) matches "^142\\.[1,2,5]{1,3}\\.(32|33)\\.[0-9]{3}"'
  915 186.636198 142.251.33.179 → 10.0.2.15    TCP 66 80 → 37398 [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=1460
  918 186.636629 142.251.33.179 → 10.0.2.15    TCP 66 80 → 37398 [ACK] Seq=1 Ack=136 Win=65535 Len=0
  919 186.651759 142.251.33.179 → 10.0.2.15    TCP 1490 HTTP/1.0 411 Length Required  [TCP segment of a reassembled PDU]
  921 186.653506 142.251.33.179 → 10.0.2.15    HTTP 355 HTTP/1.0 411 Length Required  (text/html)
  922 186.653509 142.251.33.179 → 10.0.2.15    TCP 66 80 → 37398 [FIN, ACK] Seq=1726 Ack=136 Win=65535 Len=0
  925 186.653877 142.251.33.179 → 10.0.2.15    TCP 66 80 → 37398 [ACK] Seq=1727 Ack=137 Win=65535 Len=0
```

Similarly, let's look for destinations:

```console
$ tshark -n -r securitynik_regex.pcap  -T fields -e ip.dst | sort | uniq
10.0.0.100
10.0.2.15
142.251.32.83
142.251.33.179
142.251.41.83
172.217.1.19
172.217.165.19
209.59.177.103
45.60.31.34
64.71.255.198
```

Let's now extract the destinations where we have the first octet starts with 2 numbers between 0 and 9. The second octet is exactly 0. The third octet can only have 1 number and it can only be 0 or 2. Octet 4, ends with either 100 or 15.

```console
$ tshark -n -r securitynik_regex.pcap -Y 'string(ip.dst) matches "^[0-9]{2}\\.0\\.[0,2]{1}\\.(100|15)$"' -T fields -e ip.dst | sort | uniq
10.0.0.100
10.0.2.15
```

Let's now wrap this up by grabbing some frames numbers. First up, the first frame:

```console
$ tshark -n -r securitynik_regex.pcap -Y 'string(frame.number) matches "^1$"'
    1   0.000000 08:00:27:0e:34:8d →              ARP 48 Who has 10.0.2.2? Tell 10.0.2.15
```

Next, frames 1 to 9.

```console
$ tshark -n -r securitynik_regex.pcap -Y 'string(frame.number) matches "^[0-9]$"'
    1   0.000000 08:00:27:0e:34:8d →              ARP 48 Who has 10.0.2.2? Tell 10.0.2.15
    2   0.000154 52:54:00:12:35:02 →              ARP 66 10.0.2.2 is at 52:54:00:12:35:02
    3   0.000235    10.0.2.15 → 64.71.255.198 DNS 85 Standard query 0x4872 A www.securitynik.com
    4   0.000241    10.0.2.15 → 64.71.255.198 DNS 85 Standard query 0x0d7d AAAA www.securitynik.com
    5   0.150729 64.71.255.198 → 10.0.2.15    DNS 166 Standard query response 0x4872 A www.securitynik.com CNAME www.securitynik.com.ghs.googlehosted.com CNAME ghs.googlehosted.com A 172.217.165.19
    6   5.004124    10.0.2.15 → 64.71.255.198 DNS 85 Standard query 0x4872 A www.securitynik.com
    7   5.106980 64.71.255.198 → 10.0.2.15    DNS 166 Standard query response 0x4872 A www.securitynik.com CNAME www.securitynik.com.ghs.googlehosted.com CNAME ghs.googlehosted.com A 142.251.32.83
    8   5.107044    10.0.2.15 → 64.71.255.198 DNS 85 Standard query 0x0d7d AAAA www.securitynik.com
    9   5.119889 64.71.255.198 → 10.0.2.15    DNS 178 Standard query response 0x0d7d AAAA www.securitynik.com CNAME www.securitynik.com.ghs.googlehosted.com CNAME ghs.googlehosted.com AAAA 2607:f8b0:400b:807::2013
```

Ok! I one more. We Took advantage of various fields by their names. Let's instead close this off my look at combination of offset and field.

```console
$ tshark -n -r securitynik_regex.pcap -Y '(udp[25:] matches "s.{10,20}\.com") && (string(ip.src) matches "^[0-9]{2}\\.0\\.[0,2]{1}\\.(15)$")' | more
    3   0.000235    10.0.2.15 → 64.71.255.198 DNS 85 Standard query 0x4872 A www.securitynik.com
    4   0.000241    10.0.2.15 → 64.71.255.198 DNS 85 Standard query 0x0d7d AAAA www.securitynik.com
    6   5.004124    10.0.2.15 → 64.71.255.198 DNS 85 Standard query 0x4872 A www.securitynik.com
    8   5.107044    10.0.2.15 → 64.71.255.198 DNS 85 Standard query 0x0d7d AAAA www.securitynik.com
   17   5.282030    10.0.2.15 → 64.71.255.198 DNS 85 Standard query 0x3e8d A www.securitynik.com
   18   5.282048    10.0.2.15 → 64.71.255.198 DNS 85 Standard query 0x6688 AAAA www.securitynik.com
  337  47.326990    10.0.2.15 → 64.71.255.198 DNS 85 Standard query 0x7c44 A www.securitynik.com
  338  47.327019    10.0.2.15 → 64.71.255.198 DNS 85 Standard query 0x8443 AAAA www.securitynik.com
  348  47.549609    10.0.2.15 → 64.71.255.198 DNS 85 Standard query 0x5543 A www.securitynik.com
  349  47.549690    10.0.2.15 → 64.71.255.198 DNS 85 Standard query 0x677e AAAA www.securitynik.com
  910 186.517304    10.0.2.15 → 64.71.255.198 DNS 85 Standard query 0x49f7 A www.securitynik.com
  911 186.517330    10.0.2.15 → 64.71.255.198 DNS 85 Standard query 0x9bf2 AAAA www.securitynik.com
  926 200.282904    10.0.2.15 → 64.71.255.198 DNS 85 Standard query 0x2bdf A www.securitynik.com
  927 200.282930    10.0.2.15 → 64.71.255.198 DNS 85 Standard query 0x1cd0 AAAA www.securitynik.com
```

Ok! Well that's it for finding data using TShark's contain and matches. Obviously, we don't have to use additional tools such as _grep_ to find data within packets. However, you may still find _grep_ helpful in many other cases.

References:  
[securitynik_regex.pcap - PCAP used above ](https://github.com/SecurityNik/SUWtHEh-/blob/master/securitynik_regex.pcap)

<https://sharkfestus.wireshark.org/assets/presentations16/16.pdf>  
<https://www.wireshark.org/docs/wsug_html_chunked/ChWorkBuildDisplayFilterSection.html>  
<https://www.cellstream.com/reference-reading/tipsandtricks/431-finding-text-strings-in-wireshark-captures>  
<https://www.cellstream.com/resources/2013-09-10-11-55-21/cellstream-public-documents/wireshark-related/83-wireshark-display-filter-cheat-sheet/file>  
<https://www.securityinbits.com/malware-analysis/tools/wireshark-filters/>  
<https://blog.packet-foo.com/2013/05/the-notorious-wireshark-out-of-memory-problem/>  
<https://www.wireshark.org/docs/wsdg_html_chunked/lua_module_GRegex.html>  
<https://luca.ntop.org/gr2021/altre_slides/CorsoWireshark.pdf>  
<https://stackoverflow.com/questions/9655164/regex-ignore-case-sensitivity>  
<https://www.hscripts.com/tutorials/regular-expression/metacharacter-list.php>
