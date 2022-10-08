# ArionAgent performance
## Overview

This is the performance test of Arion Agent working with ebpf/XDP as downstream programming module and ArionMaster grpc streaming server as upstream metadata source as an entire system.


## Test environment

This test is between 2 machines of the same lab, they don't belong to the same IP range (means not located on the same rack but same data center):
    
    1. Arion master server
    
    2. Arion agent (launched on the same machine of Arion Wing which is XDP as gateway network functionality)



## Arion CP performance test scenario #1 - Get/List from server to gateway programming E2E latency

* Arion Master - For 100 gateway nodes cluster
    - Single-digit us watch latency per state
    - Average 0.3 ms remotely get latency per neighbor
    - Average 1 ms write latency per neighbor

* Arion Agent List/Get data latency (data were already in DB)
    - Start time – when ArionWing calls server for getting/listing neighbor updates (from scratch, or from a specific revision)
    - End time – when ArionWing gets and finish all neighbors programming in ebpf
    - Less than 20us E2E latency (watch + eBPF programming) per state for small sized configuration (1 < state size < 100)
    - Less than 10us E2E latency per state for medium to large sized configuration (100 < state size < 1 million)

E2E programming (list batch data + programming) latency:
* 1 neighbor
    - overall latency 15us
    - per neighbor latency 15us
* 5 neighbors
    - overall latency 61us
    - per neighbor latency 12.2us
* 100 neighbors
    - overall latency 1004us = 1ms
    - per neighbor latency 10us
* 500 neighbors
    - overall latency 4803us = 4.8ms
    - per neighbor latency 9.6us
* 1k neighbors
    - overall latency 9.5ms
    - per neighbor latency 9.5us 
* 5k neighbors
    - overall latency 49.1ms
    - per neighbor latency 9.8us
* 10k neighbors
    - overall latency 93.6ms
    - per neighbor latency 9.36us
* 50k neighbors
    - overall latency 354.1ms
    - per neighbor latency 7.08us
* 100k neighbors
    - overall latency 601.4ms (and if we compare with the watch only 100k neighbors latency of 380ms, we know the overhead of 100k ebpf rule programming is 220ms)
    - per neighbor latency 6.01us
* 500k neighbors
    - overall latency 2924.6ms = 2.9 seconds
    - per neighbor latency 5.85us
* 1 million neighbors
    - overall latency 5,893 ms = 5.9 seconds
    - per neighbor latency 5.89us

![image](https://user-images.githubusercontent.com/83976250/194677460-1dbf2788-19ff-4952-8406-62743ac73373.png)

As we can see, over the increasing goal-state sizes (in one version of update) the latency for each state was lowered, due to the saved/shared gRPC communication overhead across all goal-states. 


## Arion CP performance test scenario #2 - User update neighbors to server to gateway programming E2E latency

* Arion Agent Watch Latency (user simultaneously updates neighbors to server/DB)
    - Start time – when the 1st neighbor insert/update (to server aka. ArionMaster) is called by user
    - End time – when the Nth neighbor (last in this update) is programmed in Arion Wing ebpf, means all neighbors are programmed on gateway node
    - Average 1 ms write latency per neighbor

E2E programming (write to server db + watch + programming) latency:
* 5 neighbors
    - overall 0.9ms
    - per neighbor latency 180us
* 100 neighbors
    - overall 15ms
    - per neighbor latency 150us
* 1k neighbors
    - overall 60ms
    - per neighbor latency 60us
* 10k neighbors
    - overall 748ms
    - per neighbor latency 74.8us
* 100k neighbors
    - overall 3.8s
    - per neighbor latency 38us
* 1 million neighbors
    - overall 0.9ms
    - per neighbor latency 39us

![image](https://user-images.githubusercontent.com/83976250/194678279-ec874f26-63fc-45c9-b12c-1d223c0283fa.png)
