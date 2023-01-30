# Sqlite performance
## Overview
This is performance test for security group which using sqlite as data layer. In security group design, one vpc security group can binding to multiple ports and one port
can have multiple security group. A security group can have 1000 rules. This test include write one seucrity group rule performance, read multiple security group rules performance.

## Test environment
This test are performed on AWS. 

Instance type:

      Number of vCPUs: 8
      Storage device: EBS
      RAM size: 32

## Test setup and workflow
In this test, first implement a performance testing tool using c++. In this testing tool, it include fill test performance and read performance. This tool first create a security 
group rules table. Then it random fill security group rules and compute fill performance. It also random read security group rules which are inserted and compute random read performance.
Here is security group rule schema:

![image](https://user-images.githubusercontent.com/85367145/215620686-a823a96d-4a57-4e2c-9d75-61902bf04c02.png)

## Security group performance


As show above, test key is security group rule id and value is security group rule. Security group key size is about 16 bytes and value size is about 369 bytes.

Fill 1000000 security group which have one security group rule which about 367M raw data performance:

![image](https://user-images.githubusercontent.com/85367145/215622054-f2ff22d1-73dc-4fc0-89c0-ce25a827a7f9.png)

Fill 100000 security group which have 10 security group rules performance:

![image](https://user-images.githubusercontent.com/85367145/215623147-582dfbbf-174b-4982-8a34-3128e9a112f5.png)

Fill 10000 security group which have 100 security group rules performance:

![image](https://user-images.githubusercontent.com/85367145/215623287-a4414f3c-ad57-4cb3-a441-074ad6a597f9.png)


