# socat: The General Bidirectional Pipe Handler

The [socat](http://www.dest-unreach.org/socat/) command shuffles data between two locations. One way to think of socat is as the cat command which transfers data between two locations rather than from a file to standard output. I say that socat works on two locations rather than two files because you can grab data from a network socket, named pipe, or even setup a general virtual network interface as one end point. In this article, we’ll take a look at socat and a few of its uses and end up creating a VPN over an ssh connection using a single command from the ssh client side.

Because socat allows bidirectional data flow between the two locations you specify, it doesn’t really matter which order you specify them in. Locations have the general form of `TYPE:options` where `TYPE` can be `CREATE`, `GOPEN` or `OPEN` for normal filesystem files. There are also shortcuts for some locations like `STDIO` (or just `-`) which reads and writes to standard input and output respectively.

The `SYSTEM` type can be used to execute a program and connect to its standard input and output. For example, the command shown below will run the date command and transfer its output to standard output.

```console
$ socat SYSTEM:date -
Thu Apr 23 12:57:00 EST 2009
```

Many network services handle control commands using plain text. For example, SMTP servers, HTTP servers. The below socat command will open a connection to a Web server and fetch a page to the console. Notice that the port is specified using the service name and a comma separates the address from the `cnrl` option which handles line termination transformations for us.

```console
$ socat - TCP:localhost:www,crnl
GET /


...
```

If the network service is more interactive, you might like to use readline to track your command history, improve command editing, and allow you to search and recall your previous commands. Instead of connecting standard IO as the first location in the above command, using `READLINE,history=\$HOME/.http_history` will cause socat to use readline to get your commands.

Many of the socat location TYPEs take more than one option. For example, GOPEN (generic open) lets you specify append if you would like to append too rather than overwrite the file. The below keeps a log file of the time each time you execute it. This is similar to the Web server example, a comma separated list of additional options for the location.

```console
$ date | socat - GOPEN:/tmp/capture,append
```

While this example is quite superfluous in that you could just use the shell `>>` redirection to append to the file, you could also include a network link into the mix with minimal effort using socat as shown below. The first command connects port 3334 on `localhost` to the file `/tmp/capture`. The seek-end moves the file to zero bytes from the end and the append makes sure that bytes are appended to the file rather than overwriting it. The client command, shown as the second command below, is very similar to the simpler example shown above except we now send standard IO to a socket address.

```console
$ socat TCP4-LISTEN:3334,reuseaddr,fork gopen:/tmp/capture,seek-end=0,append

$ date | socat STDIO tcp:localhost:3334
```

One great use case for socat is making device files from one machine available on another one. I’ll use the example from the socat manual page shown below to demonstrate. The first location creates a PTY device on the local machine allowing raw communication with the other location. The other location is an ssh connection to a server machine, where the standard IO is connected to the serial device on the remote machine.

```bash
(socat PTY,link=$HOME/dev/vmodem0,raw,echo=0,waitslave
 EXEC:"ssh   modem-server.example.com socat - /dev/ttyS0,nonblock,raw,echo=0")
```

While creating virtual modems is not as attractive as it might once have been, other devices can be moved around too. The below command makes `/dev/urandom` from a server available through a named pipe on the local machine.

```bash
socat
  PIPE:/tmp/test/foo
  SYSTEM:"ssh myserver socat - /dev/urandom"
```

### Creating a Virtual Private Network over SSH in a Single Line

Virtual networks are created using the TUN device of the Linux kernel. Note that if you send data to a TUN device there is no encryption happening so if those packets move over the real network you have a Virtual _Public_ Network. While there are overviews of using [socat with TUN](http://www.dest-unreach.org/socat/doc/socat-tun.html) and [socat with SSL](http://www.dest-unreach.org/socat/doc/socat-openssltunnel.html) I think it is much simpler to just use SSH to protect the network link from eavesdropping. You probably already have SSH setup so its much simpler to use because no SSL certificates need to be generated and distributed. The trick with using ssh is how to bolt things together. You could setup port forwarding with ssh and use socat to connect those ports to a virtual TUN device. But that leaves forwarded ports between the two hosts which serve no legitimate purpose other than servicing the socat TUN devices.

It is clear that one end point will be a direct TUN location, and the other is leaning towards being an ssh into the remote host. The trick is making the ssh into the remote host use socat to connect its standard IO to a TUN device. So we use socat twice in the one command: once to connect a TUN to an ssh session on the local machine, and once to connect standard IO to a TUN device on the remote end.

The below command will setup the `192.168.32.2` address on localhost to communicate with `192.168.32.1` on the server host over a VPN. If you use the `192.168.32.1` address you should be able to connect to network services on the server as though it was on the LAN.

The first location just sets up a local TUN device with an address and brings the network interface up. The second location will ssh into the server machine and run socat there to connect the standard IO of the ssh session to a TUN device on the server. The `-d -d` options can be selectively removed to remove the debugging chatter from the local and remote socat processes but are very informative when experimenting.

```console
# socat -d -d
    TUN:192.168.32.2/24,up
    SYSTEM:"ssh root@server socat -d -d  - 'TUN:192.168.32.1/24,up'"
```

You might need to be root to create TUN devices. If socat can not make them as the current user you will see a message like the below.

```console
2009/04/23 14:41:09 socat[17930] E ioctl(3, TUNSETIFF, {""}: Operation not permitted
```

socat is a great tool to have in your collective command line toolbox. There are options to use socat with tcpwrappers, and a huge array of the parameters that can be set on sockets and other through other low level system calls can be tweaked through parameters to socat.

The ability to setup a makeshift VPN using ssh for data protection using a one line command could be just what you are after when you want to get at a few services without needing to research which ports you need to forward.
