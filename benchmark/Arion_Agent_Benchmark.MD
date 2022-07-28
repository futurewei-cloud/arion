# ArionAgent performance
## Overview

This is the performance test of Arion Agent working with ebpf/XDP as downstream programming module and ArionMaster grpc streaming server as upstream metadata source as an entire system.


## Test environment

This test is between 2 machines of the same lab, they don't belong to the same IP range (means not located on the same rack but same data center):
    
    1. Arion master server
    
    2. Arion agent (launched on the same machine of Arion Wing which is XDP as gateway network functionality)


## Test workflow and scenario #1 - watch from Arion Master only latency

Latency = ArionAgent finishes receiving N number of neighbors - start to receive Grpc neighbors time (right after watch call to ArionMaster Grpc server finished)

Watch performance from ArionMaster:
    
		Watch 5 neighbors performance: 31 us
    
		Watch 100k neighbors performance: 379,270 us = ~380 ms


## Test workflow and scenario #2 - E2E ebpf programming latency

Latency = Finish ebpf map programming time - start to receive Grpc neighbors time (right after watch call to ArionMaster Grpc server finished)

E2E programming (watch + programming) performance:
    
		100k neighbors performance: 455,059 us = ~455 ms (and if we compare with the watch only 100k neighbors latency of 380ms, we know the overhead of 100k ebpf rule programming is 75ms)
		
		1 million neighbors performance: 5,044,295 us = 5,044 ms = 5 seconds
