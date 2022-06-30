# Arion master performance
## Overview

This is performance test for Arion master server with Hazelcast as data cache layer. It include read performance test, write performance test and watch performance test. 
For read performance test, there are two test which are grpc unary read performance and grpc streaming read performance.

## Test environment
This test on AWS ec2 instances. It include three instances:

	1 Arion master server
	2 Hazelcast database
	3 ghz test client https://github.com/bojand/ghz
	
Instance type:

          96 vCPU
          192 RAM

## Test setup and workflow
![image](https://user-images.githubusercontent.com/85367145/176714897-666c440d-7eb8-478f-add8-65621ecf7729.png)

Read test:

	Request meta data:
	
		message Request
		{
		    message Resource
			[
			   {
			        Request id
			        IP
			        VNI
			    }
			]
		 }
	
	Response meta data:
	
		Message Response
		{
			  message Neighbor Rule Reply 
			  [
				{
				        Request id
				        Neighbor rule
				}
			  ]
	           }
		
	GRPC unary test:
	
		1 Send 1000000 request to Arion master
		2 Get 1000000 response
	
	GRPC streaming test:
    
	        1 Send 100 request to Arion master
			i. Send 1000 streaming request to Arion master
	        2 Get 100 Response 
			i. Get 1000 streaming response

Write test:
	
	Request meta data:
		message Neighbor Rules Request
		{
		   neighbors 
			[
				Neighbor Rule
			]
		}
		
	Response meta data:
	
		Message Goal State Operation Reply
		{
			Goal State Operation Status 
			{
				Operation Type
				Operation Status
			}
		}
	
	GRPC unary test:
		1 Send 1000000 request to Arion master
		2 Get 1000000 response
	
Watch test:

	Request meta data:
		
		Message Arion Wing Request 
		{
			Version
			Group
		}
		
	Response meta data:
		
		Message Neighbor Rule 
		{
			Neighbor Rules
			[
				{
					Neighbor RUle
				}
			]
		}

## Arion master performance
Read performance:

	GRPC unary performance:
	
		Summary:
		  Count:        1000000
		  Total:        24.98 s
		  Slowest:      11.11 ms
		  Fastest:      0.15 ms
		  Average:      0.30 ms
		  Requests/sec: 40036.06
		
		Response time histogram:
		  0.155  [1]      |
		  1.250  [992949] |∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎
		  2.346  [5063]   |
		  3.441  [1102]   |
		  4.537  [376]    |
		  5.632  [176]    |
		  6.728  [114]    |
		  7.824  [112]    |
		  8.919  [67]     |
		  10.015 [34]     |
		  11.110 [6]      |
		
		Latency distribution:
		  10 % in 0.20 ms
		  25 % in 0.22 ms
		  50 % in 0.25 ms
		  75 % in 0.31 ms
		  90 % in 0.39 ms
		  95 % in 0.53 ms
		  99 % in 1.11 ms
		
		Status code distribution:
		  [OK]   1000000 responses
	
	GRPC streaming performance:
		
    	Summary:
		  Count:        100
		  Total:        189.03 ms
		  Slowest:      83.86 ms
		  Fastest:      31.48 ms
		  Average:      51.29 ms
		  Requests/sec: 529.02
		
		Response time histogram:
		  31.483 [1]  |∎∎
		  36.721 [8]  |∎∎∎∎∎∎∎∎∎∎∎∎∎
		  41.958 [16] |∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎
		  47.196 [15] |∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎
		  52.434 [24] |∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎
		  57.671 [13] |∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎
		  62.909 [7]  |∎∎∎∎∎∎∎∎∎∎∎∎
		  68.146 [5]  |∎∎∎∎∎∎∎∎
		  73.384 [2]  |∎∎∎
		  78.621 [4]  |∎∎∎∎∎∎∎
		  83.859 [5]  |∎∎∎∎∎∎∎∎
		
		Latency distribution:
		  10 % in 36.88 ms
		  25 % in 41.90 ms
		  50 % in 49.20 ms
		  75 % in 56.54 ms
		  90 % in 68.42 ms
		  95 % in 78.38 ms
		  99 % in 82.37 ms
		
		Status code distribution:
		  [OK]   100 responses

		
Write performance:
	
	GRPC unary performance:
    
		Summary:
		  Count:        1000000
		  Total:        27.86 s
		  Slowest:      9.02 ms
		  Fastest:      0.51 ms
		  Average:      1.01 ms
		  Requests/sec: 35895.52
		
		Response time histogram:
		  0.515 [1]      |
		  1.365 [912706] |∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎
		  2.215 [77669]  |∎∎∎
		  3.065 [7610]   |
		  3.915 [1692]   |
		  4.765 [245]    |
		  5.615 [47]     |
		  6.465 [21]     |
		  7.315 [3]      |
		  8.165 [2]      |
		  9.016 [4]      |
		
		Latency distribution:
		  10 % in 0.75 ms
		  25 % in 0.83 ms
		  50 % in 0.93 ms
		  75 % in 1.09 ms
		  90 % in 1.32 ms
		  95 % in 1.57 ms
		  99 % in 2.20 ms
		
		Status code distribution:
		  [OK]   1000000 responses

Watch performance:
    
    Directly watch Hazelcast
    
		Hazelcast 100k neighbor data performance: 500 ms
    
    Watch Arion master
    
		ArionMaster 100k neighbor data performance: 1.2 s 





