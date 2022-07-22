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


Table

![image](https://user-images.githubusercontent.com/85367145/180321277-9ebbc808-5ea9-4015-847d-35c454ab53f0.png)

Charts

![image](https://user-images.githubusercontent.com/85367145/180293767-194a8ec7-8386-4cb0-bac4-781bd3e83eb4.png)

![image](https://user-images.githubusercontent.com/85367145/180296041-e56a33c5-c854-41c3-b6eb-aea3981f20be.png)

From the table, we can see that QPS and latency almost stay the same no matter how the number of VPC's/subnets changes. Thus, the conclusion is the number of VPC's/subnets is unrelated to performance.

### Arion master QPS test

In this test, it performs step by step load from RPS = 10,000 to RPS = 60,000 in order to get Arion master QPS.

Table

![image](https://user-images.githubusercontent.com/85367145/180319407-5c4dcace-502d-42b4-934f-862c1719de22.png)

Charts

![image](https://user-images.githubusercontent.com/85367145/180326004-578c7713-22e4-4bb4-9091-ed9229ae827b.png)

![image](https://user-images.githubusercontent.com/85367145/180322684-69b238d5-f5dd-4426-ab77-720102382988.png)

From the charts above, we can see that QPS grows as RPS increases. It reaches its peak when RPS is about 40,000. QPS remains stable with a slight drop as RPS continues to increase. The reason for the minor QPS drop is that the requests queued on server consume some resources. Average latency also grows as RPS increases.

### Arion master clients number supporting test

This is a test for how many clients Arion master server can support and their coresponding performance.

Table

![image](https://user-images.githubusercontent.com/85367145/180326483-12891187-44d0-4def-9c12-aef3e7a0632f.png)

Charts

![image](https://user-images.githubusercontent.com/85367145/180326808-d9a3088f-2532-4959-ba5c-986d5cf2a548.png)

![image](https://user-images.githubusercontent.com/85367145/180326850-bb826699-c41e-46d9-985e-423bbff9eabe.png)

The charts above show us that, QPS improves when the number of clients grows. It reaches the optimal value when the number of clients is around 30. After that QPS almost stops growing. However, lentency keeps increasing while the number of clients grows. It exeeds 1.0 ms when there are 300 clients and increases dramatically as more clients are added. Thus, if we want to keep latency below 1.0ms, the number of clients should not exeed 300. 


### Unary query compare to streaming query

This is a test for comparison Unary query performance with streaming query performance.

Table

![image](https://user-images.githubusercontent.com/85367145/176919485-efba4c8d-4d02-4287-bdcd-0a32dfcf089f.png)

Charts

![image](https://user-images.githubusercontent.com/85367145/180327864-b8f40d36-195f-43ff-ad98-fbf7651bdaa0.png)

![image](https://user-images.githubusercontent.com/85367145/180327874-eae79dcb-567c-4161-b970-fd2662572032.png)

From table and charts above, streaming query performance is much better than unary query. Streaming query need client handle requests.


### 30 clients performance

30 clients have a better performance as RPS reach it's QPS with low latency. Every clients can send about 150 requests.

![image](https://user-images.githubusercontent.com/85367145/180331124-08c18428-1b66-4045-9577-94e45a655d50.png)

	
Write performance:
	
![image](https://user-images.githubusercontent.com/85367145/180335655-f81b194a-2e7d-4d49-a0c6-148d53c4cb29.png)	

Watch performance:
    
    Directly watch Hazelcast
    
		Hazelcast 100k(6M) neighbor data performance: 500 ms
    
    Watch Arion master
    
		ArionMaster 100k(6M) neighbor data performance: 1.2 s 





