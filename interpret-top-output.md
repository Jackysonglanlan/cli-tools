<!-- from: https://www.redhat.com/sysadmin/interpret-top-output -->

# What the first five lines of Linux's top command tell you

The **top** utility is a commonly used tool for displaying system-performance information. It dynamically shows administrators which processes are consuming processor and memory resources. Top is incredibly handy.

While most administrators quickly grasp the lower portion of top's output, the upper part is harder to interpret. So this article explains the five lines displayed at the top of top:

- `top` displays uptime information
- `Tasks` displays process status information
- `%Cpu(s)` displays various processor values
- `MiB Mem` displays physical memory utilization
- `MiB Swap` displays virtual memory utilization

## Uptime <a id="uptime" ></a>

Top's first line, **top**, shows the same information as the `uptime` command. The first value is the system time. The second value represents how long the system has been up and running, while the third value indicates the current number of users on the system. The final values are the load average for the system.

The load average is broken down into three time increments. The first shows the load for the last one minute, the second for the last five minutes, and the final value for the last 15 minutes. The results are a percentage of CPU load between 0 and 1.0. The processor is likely overworked if 1.0 (or higher) is displayed.

```txt
top - 23:03:09 up 4 min, 1 user, load average: 0.75, 0.59, 0.25
```

## Tasks <a id="tasks" ></a>

The second line is the **Tasks** output, and it's broken down into five states. These five states display the status of processes on the system:

- `total` shows the sum of the processes from any state.
- `running` shows how many processes are handling requests, executing normally, and have CPU access.
- `sleeping` indicates processes awaiting resources, which is a normal state.
- `stopped` reports processes exiting and releasing resources; these send a termination message to the parent process.
- `zombie` refers to a process waiting for its parent process to release it; it may become orphaned if the parent exits first.

Zombie processes usually mean an application or service didn't exit gracefully. A few zombie processes on a long-running system are not usually a problem.

```txt
Tasks: 220 total, 3 running, 217 sleeping, 0 stopped, 0 zombie
```

## %Cpu(s) <a id="cpu-s" ></a>

Values related to processor utilization are displayed on the third line. They provide insight into exactly what the CPUs are doing.

- `us` is the percent of time spent running user processes.
- `sy` is the percent of time spent running the kernel.
- `ni` is the percent of time spent running processes with manually configured [nice values](https://www.redhat.com/sysadmin/manipulate-process-priority).
- `id` is the percent of time idle (if high, CPU may be overworked).
- `wa` is the percent of wait time (if high, CPU is waiting for I/O access).
- `hi` is the percent of time managing hardware interrupts.
- `si` is the percent of time managing software interrupts.
- `st` is the percent of virtual CPU time waiting for access to physical CPU.

Values such as `id`, `wa`, and `st` help identify whether the system is overworked.

```txt
%Cpu(s): 19.3 us, 4.0 sy, 0.0 ni, 74.7 id, 0.0 wa, 0.3 hi, 1.7 si, 0.0 st
```

## MiB Memory <a id="mib-memory" ></a>

The final two lines of top's output provide information on memory utilization. The first line—`MiB Mem`—displays physical memory utilization. This value is based on the total amount of physical RAM installed on the system.

```txt
MiB Mem: 3898.5 total, 385.2 free, 1167.0 used, 2346.2 buff/cache
```

**Note**: The term _mebibyte_ (and similar units, such as kibibytes and gibibytes) differs slightly from measurements such as megabytes. Mebibytes are based on 1024 units, and megabytes are based on 1000 units (decimal). Most users are familiar with the decimal measurement, but it is not as accurate as the binary form. The top utility reports memory consumption in decimal.

- `total` shows total installed memory.
- `free` shows available memory.
- `used` shows consumed memory.
- `buff/cache` shows the amount of information buffered to be written.

## MiB Swap <a id="mib-swap" ></a>

Linux can take advantage of virtual memory when physical memory space is consumed by borrowing storage space from storage disks. The process of swapping data back and forth between physical RAM and storage drives is time-consuming and uses system resources, so it's best to minimize the use of virtual memory.

```txt
MiB Swap: 3898.0 total, 3898.0 free, 0.0 used, 2433.1 avail Mem
```

- `total` shows total swap space.
- `free` shows available swap space.
- `used` shows consumed swap space.
- `buff/cache` shows the amount of information cached for future reads.

In general, a high amount of swap utilization indicates the system does not have enough memory installed for its tasks. The solution is to either increase RAM or decrease the workload.

## Wrap up <a id="wrap-up" ></a>

Glancing at the bottom 75% of top's output gives you a sense of what processes are consuming the most resources on the system. This information is often sufficient for many needs. However, the upper portion of top's output allows you to delve more deeply into exactly how the system is performing and whether CPU or RAM (or both) are utilized effectively.
