# ArionAgent performance
## Overview

This is the performance test of Arion Agent working with ebpf/XDP as downstream programming module and ArionMaster grpc streaming server as upstream metadata source as an entire system.


## Test environment

This test is between 2 machines of the same lab, they don't belong to the same IP range (means not located on the same rack but same data center):
    
    1. Arion master server
    
    2. Arion agent (launched on the same machine of Arion Wing which is XDP as gateway network functionality)


## Test workflow and scenario #1 - watch from Arion Master only latency (ArionAgent as c++ grpc client)

Latency = ArionAgent finishes receiving N number of neighbors - start to receive Grpc neighbors time (right after watch call to ArionMaster Grpc server finished)

Watch performance from ArionMaster:
* Watch 5 neighbors performance: 31 us
* Watch 100k neighbors performance: 379,270 us = ~380 ms


## Test workflow and scenario #2 - E2E ebpf programming latency

Latency = Finish ebpf map programming time - start to receive Grpc neighbors time (right after watch call to ArionMaster Grpc server finished)

E2E programming (watch + programming) latency:
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
