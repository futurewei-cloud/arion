# Arion DP Benchmark

## Introduction

This is the initial benchmark for Arion DP network performance. We mainly conducts the Throughput and Latency Benchmark and primarily focus on tests on single Wing performance. The numbers will be used for understanding current Arion DP behaviour and furthuer exploring performance improvement for single wing as well Ariond DP cluster.

We used different tools to conduct various benchmark tests. The results shown below are mainly collected with netperf although we also used iperf3 for comparision. The throughput benchmark uses netperf's TCP_STREAM. TCP_RR and TCP_CRR are used to observe network latency.

The main comparision in benchmarking is between direct compute node communication vs communication via Arion Cluster between computer nodes.

## Test environment

The Ariond DP cluster is set up with: 
 - 6 bare-metal machines as Arion Wings
 - 12 bare-matal machines as Computer Nodes
	
Each Arion Wing in Arion cluster runs with Ubuntu 22.04. Computer Nodes run with Ubuntu 18.04.

  - CPU
    * Intel(R) Xeon(R) CPU E5-2640  0 @ 2.50GHz 12 cores/24 threads  (Wing)
    * Intel(R) Xeon(R) CPU E5-2620 v4 @ 2.10GHz 16 cores/32 threads(Compute Node)
  - Network Card: Intel 82599ES 10-Gigabit SFI/SFP+ 
  - Kernel 
    * Linux 5.15(Ubuntu 22.04 LTS) (Wing)
    * Linux 4.15(Ubuntu 18.04 LTS) (Compute Node)

These machines are connected via 10G switches.

## Test setup

The tests shown here includes:
  - Direct(Node <-> Node): In this setup, no Arion Cluster is envolved. The benchnark is performed by directly running *netperf* between docker containers in different bare metal machines with differnt MTUs:
      * MTU 1500
	  * MTU 9000

  - Via Arion Cluster(Node <-> Wing <-> Node): In this setup, all traffic goes through a single Arion Wing, no direct path is allowed. same *netperf* tests are conducted for following setup:
      * MTU 1500, generic mode
	  * MTU 1500, generic mode, offband oam notification on
	  * MTU 1500, driver mode
	  * MTU 9000, generic mode

## Summary of the Results

While the results are still prelimilary, the tests are done with in house (*humble*) 10G network invironment and Arion DP is work in progress with more optimization and features to be add on, we feel initial finding is meaningful and could serve as a baseline for following development. Below are some current observations about Arion DP: 
 - communication via Arion Wing can reach about the same throughput as direct communication between compute nodes with neibhgour rules(close to line rate);
 - there are about *30us* extra network delay to go through Arion Wing(CN-Arion-CN) in netperf TCP_RR test compared with direct CN-CN path;
 - enabling XDP Driver mode has about *7%* performance improvement(both throughput and latency);
 - enabling offband Direct Path OAM capability in Arion DP has about *15%* performance downgrade in terms of throughput;
 - XDP/eBPF program needs to be carefully written with performance concern in mind, the existing Arion DP performance has more than *doubled* compared to the initial version.

 We also did some Arion Cluster performance tests. This part of benchmarking is not completed as some key Arion cluster feature(e.g. sharding) are not completed and not well tested yet.


## The Throughput Benchmark 

Netperf TCP throughput metric measuring the maximum data transfer rate between containers running on different nodes, which is the *netperf*'s default test. 

![tcp_stream](https://user-images.githubusercontent.com/83482178/176801547-793c3f38-e079-415b-9f17-cee79b94538c.png)


The above graph shows the maximum throughput that can be achieved with a single TCP connection. With MTU set as 9000, both Node to Node and via Arion reaches about *9.5* Gbps for 10G Nic interface with across Arion has slight higher throughput(*+2.5%*); With default MTU(1500), via arion and direct reaches about the same throughput; driver mode reach *6.5%* higher throughput while turn on direct path OAM downgrades throughput by *15%*. 

| Config	 | MTU	  | Througphut(Mbps) | Difference(%) |
| :---       | :---:  | :---:            |          ---: |
| via arion	 |	1500  |	4995.24          | 	  99.3%      |
| drv mode	 |	1500  |	5358.07 	     |	  106.5%     |
| DP OAM on  |	1500  |	4275.28 		 |    85.0%      |
| direct	 |  1500  |	5031.76 		 |    100%       |
|        |   |             |           |
| via arion  |	9000  |	9664.98 		 |    102.5%     |
| direct	 |  9000  |	9426.22 		 |    100%       |

The tests are measured by running *netperf* using the *TCP_STREAM* test. Since the test is mostly done using a single core for network processing(as also observed during the test), for default mtu 1500 tests, above number is constrained by the available CPU resources of a single core(CPU is the bottleneck). An interesting observation is XDP/eBPF driver mode has noticable better throughput than direct connect. This can be further studied.

TCP throughput benchmark is extreamly useful for applications like:
 - AL/ML applications which requre access to large amount of data;
 - Media streaming services.

## Latency: Requests per Second
The request per second metric measures the rate of single byte round-trips that can be performed in sequence over a single persistent TCP connection. It can be thought of as a user-space to user-space ping with no think time - it is by default a synchronous, one transaction at a time, request/response test.
This benchmark highlights how effeciently a single network packet can be processed.


![tcp_rr1](https://user-images.githubusercontent.com/83482178/176801679-30840f65-299f-4cfc-a82f-f178154a5bbb.png)

![tcp_rr2](https://user-images.githubusercontent.com/83482178/176801744-9c503d21-1563-4442-8ad3-8e8b3673d124.png)



## Latency: Rate of new Connections
This test measures the performance of establishing a connection, exchanging a single request/response transaction, and tearing-down that connection. This is very much like what happens in an HTTP 1.0 or HTTP 1.1 connection when HTTP Keepalives are not used.

![tcp_crr1](https://user-images.githubusercontent.com/83482178/176801768-34ebc7ec-afd2-435b-ad73-5eacd3fc0a69.png)

![tcp_crr2](https://user-images.githubusercontent.com/83482178/176801807-63c3a2d8-6e1c-4840-9592-5ba40715a05a.png)
