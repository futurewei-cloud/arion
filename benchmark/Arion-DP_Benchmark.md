# Arion DP Benchmark
07/21/2022

v0.2
## Introduction

This is the initial benchmark for Arion DP network performance. We mainly conducted the Throughput and Latency Benchmark and primarily focus on tests on single Wing performance. The numbers will be used for understanding current Arion DP behaviour and furthuer exploring performance improvement for single wing as well as Ariond DP cluster.

We used different tools to conduct various benchmark tests. The results shown below are mainly collected with netperf tests, although we also used iperf3 for comparision. The throughput benchmark uses netperf's TCP_STREAM test. TCP_RR and TCP_CRR are used to observe network latency.

The main comparision in benchmarking is between direct compute node communication vs communication via Arion Cluster between compute nodes, as well as via legacy zeta cluster between compute nodes.

## Test environment

The Ariond DP cluster is set up with: 
 - 6 bare-metal machines as Arion Wings
 - 12 bare-matal machines as Compute Nodes
	
Each Arion Wing in Arion cluster runs with Ubuntu 22.04. Compute Nodes run with Ubuntu 18.04.

  - CPU
    * Intel(R) Xeon(R) CPU E5-2640  0 @ 2.50GHz 12 cores/24 threads  (Wing)
    * Intel(R) Xeon(R) CPU E5-2620 v4 @ 2.10GHz 16 cores/32 threads(Compute Node)
  - Network Card: Intel 82599ES 10-Gigabit SFI/SFP+ 
  - Kernel 
    * Linux 5.15(Ubuntu 22.04 LTS) (Wing)
    * Linux 4.15(Ubuntu 18.04 LTS) (Compute Node)

Zeta cluster is setup with Ubuntu 18.04 with Linux kernel updated to 5.6 under the same hardware type.

These machines are connected via 10G switches.

## Test setup

The tests shown here includes:
  - Direct(Node <-> Node): In this setup, no Arion Cluster is envolved. The benchmark is performed by directly running *netperf* between docker containers in different bare metal machines with differnt MTUs:
    * MTU 1500
    * MTU 9000

  - Via Arion Cluster(Node <-> Wing <-> Node): In this setup, all traffic goes through a single Arion Wing, no direct path is allowed. Same *netperf* tests are conducted for following setup:
    * MTU 1500, generic mode
    * MTU 1500, generic mode, offband oam notification on
    * MTU 1500, driver mode
    * MTU 9000, generic mode

  - Legacy zeta cluster(Node <-> Zeta <-> Node): In this setup, single flow traffic goes through a specific Zeta GW node, no direct path is allowed. Same *netperf* tests are conducted for the following setup:
    * MTU 1500, generic mode
    * MTU 9000, generic mode (*can't* set up)
## Summary of the Results

The tests are done with in house (*humble*) 10G network environment. Although Arion DP is work in progress with more optimization and more features to be added on, we feel the initial finding in benchmarking is meaningful and could serve as a baseline for further development. Below are some observations about current Arion DP: 
 - communication via Arion Wing can reach about the same throughput as direct communication between compute nodes with neighbour rules(*close to line rate*);
 - Network delay to go through Arion Wing(CN-Arion-CN) in netperf TCP_RR test compared with direct CN-CN path can be as low as *21us*(XDP driver mode);
 - enabling XDP Driver mode has about *7%* performance improvement(both throughput and latency);
 - enabling offband Direct Path OAM capability in Arion DP has about *15%* performance downgrade in terms of throughput;
 - Arion DP can reach about *9.6Gbps* in 10G environment, legacy zeta cluster can only reach about 3.0Gbps, this is 3X difference. We can break down the causes as following:
    * XDP/eBPF is an active evolving technology, while legacy zeta uses libbpf v0.3(01/03/2021), Arion DP uses libbpf v0.8 (5/16/2022). Optimizations, bug fixes and new capabilities are added in recent year;
    * legacy Zata reaches about 3.0Gbps in our benchmarking tests, we can only use default MTU 1500, changing MTU causes the system not functional(Compute nodes can't ping each other via Zeta after trying MTU change), current Zeta is not robust as we experinced inconsistent behaviour from time to time, both in terms of functionality and performance;
    * For comparision purpose, we tried Arion DP with literally all zeta functionalities added, the throughput can reach to about 4.0Gbps(MTU 1500), this is 33% difference, newer libbpf as well as Linux kernel optimization are the main reasons for the performance increase;
    * Arion DP reaches about 5.0Gbps(MTU 1500), which is another 33% increase in throughput; this is caused by removing unnecessary functionalities and other minor optimizations;
    * Arion DP with driver mode reaches 5.3x Gbps(MTU 1500), a 7% increase;
    * For benchmarking purpose, we can set MTU to 9000 in Arion DP cluster, this boosts the throughput to 9.6Gbps.

 - XDP/eBPF program needs to be carefully written with performance concern in mind, we've seen obvious performance difference in above analysize, as the scenerios Arion DP to face becomes more complex, how careful XDP/eBPF is written matters.  

 We also did some Arion Cluster performance tests. This part of benchmarking is not completed as some key Arion cluster feature(e.g. sharding) are not completed and not well tested yet.


## The Throughput Benchmark 

Netperf TCP throughput metric measures the maximum data transfer rate between containers running on different nodes, which is the *netperf*'s default test. 

![tcp_stream](https://user-images.githubusercontent.com/83482178/180340802-98fe44dc-c529-4109-89da-9c6b1f8ee21e.png)


The above graph shows the maximum throughput that can be achieved with a single TCP connection. With MTU set as 9000, both Node to Node and via Arion reaches about *9.6* Gbps for 10G Nic interface with across Arion has slight higher throughput(*+2.5%*); With default MTU(1500), via arion and direct reaches about the same throughput; driver mode reaches *6.5%* higher throughput while turning on direct path OAM downgrades throughput by *15%*. 

| Config	 | MTU	  | Througphut(Mbps) | Difference(%) |
| :---       | :---:  | :---:            |          ---: |
| Zeta    	 |	1500  |	3073.6          | 	  61.1%      |
| DP OAM on  |	1500  |	4275.28 		   |    85.0%      |
| via Arion	 |	1500  |	4995.24          | 	  99.3%      |
| drv mode	 |	1500  |	5358.07 	     |	  106.5%     |
| direct	 |  1500  |	5031.76 		 |    100%       |
|        |   |             |           |
| via Arion  |	9000  |	9664.98 		 |    102.5%     |
| direct	 |  9000  |	9426.22 		 |    100%       |

The tests are measured by running *netperf* using the *TCP_STREAM* test. Since the test is mostly done using a single core for network processing(as also observed during the test), for default mtu 1500 tests, above number is constrained by the available CPU resources of a single core(CPU is the bottleneck). An interesting observation is XDP/eBPF driver mode has noticable better throughput than direct connect. This can be further studied.

TCP throughput benchmark is extreamly useful for applications like:
 - AL/ML applications which requre access to large amount of data;
 - Media streaming services.

## Latency: Requests per Second
The request per second metric measures the rate of single byte round-trips that can be performed in sequence over a single persistent TCP connection. It can be thought of as a user-space to user-space ping with no think time - it is by default a synchronous, one transaction at a time, request/response test.
This benchmark highlights how effeciently a single network packet can be processed.


![tcp_rr1](https://user-images.githubusercontent.com/83482178/180340898-7cf17a41-8deb-4814-a5e4-6d4cdf17b50a.png)

![tcp_rr2](https://user-images.githubusercontent.com/83482178/180340959-704dc546-8961-4094-8dbe-fb6d901fb724.png)



## Latency: Rate of new Connections
This test measures the performance of establishing a connection, exchanging a single request/response transaction, and tearing-down that connection. This is very much like what happens in an HTTP 1.0 or HTTP 1.1 connection when HTTP Keepalives are not used.

![tcp_crr1](https://user-images.githubusercontent.com/83482178/180341014-5b09cb38-8baa-4fe0-b2e1-47a12bc3a2a3.png)

![tcp_crr2](https://user-images.githubusercontent.com/83482178/180341154-4bc03a36-c650-4fd6-8c1f-7bcfc4209cdd.png)
