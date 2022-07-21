# Arion master performance
## Overview

This is performance test for Arion master server with Hazelcast as data cache layer. It includes read performance test, write performance test and watch performance test. 

For read performance test, there are two tests: gRPC unary read performance and gRPC streaming read performance. It includes one Arion master QPS, how many clients one Arion master can support and the performance for these clients. The numbers help to better understand how many clients one Arion master can support with a certain latency.

For watch performance, watch is a stream query based on some conditions. Data recorder will send from Arion master to Arion client (Arion Wing) if the condition is ture. This test includes watch performance to download 100,000 (about 6M) routing rules.

For Write performance, it performs on inserting 100,000 routing rule and the latency to insert these data.

## Test environment
The tests are performed on AWS. There are 3 test ec2 instances:

	1 Arion master server
	2 Hazelcast database
	3 ghz test client https://github.com/bojand/ghz
	
Instance type:

	Number of vCPUs: 96
	Storage device: EBS
	RAM size: 192

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
### Test based on VPC and Neighbor rules


Table:

![image](https://user-images.githubusercontent.com/85367145/180293946-614b67a1-463a-47dd-9e65-1918384e52cf.png)

Charts

![image](https://user-images.githubusercontent.com/85367145/180293767-194a8ec7-8386-4cb0-bac4-781bd3e83eb4.png)

![image](https://user-images.githubusercontent.com/85367145/180296041-e56a33c5-c854-41c3-b6eb-aea3981f20be.png)

From the table, we can see that QPS and latency almost stay the same no matter how the number of VPC's/subnets changes. Thus, the conclusion is the number of VPC's/subnets is unrelated to performance.

Unary query compare to streaming query:

![image](https://user-images.githubusercontent.com/85367145/176919485-efba4c8d-4d02-4287-bdcd-0a32dfcf089f.png)

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
    
		Hazelcast 100k(6M) neighbor data performance: 500 ms
    
    Watch Arion master
    
		ArionMaster 100k(6M) neighbor data performance: 1.2 s 





