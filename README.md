# aws-terraform-project

## Steps

### 1. Create VPC
A vpc is a virtual private that allows to launch resoruces into a virtual netork. Each vpc is independent of each other. 
### 2. Create Internet Gateway
An internet gateway is resource to enable access to and from internet, is necessary to have an vpc. 
### 3. Create custom route table
A route table contains a set of rules, called routes, that are used to determine where network traffic from your subnet or gateway is directed.
### 4. Create a subnet.
A subnet is a range of IP addresses in your VPC. You can attach AWS resources, such as EC2 instances and RDS DB instances, to subnets. You can create subnets to group instances together according to your security and operational needs.
### 1. Associate subnet with Route Table
### 2. Create Security Group to allow port 22, 80, 443
### 3. Create a network interface with an ip in the subnet that was created in step 4
### 4. Assign an elastic IP to the network interface created in step 7
### 5. Create Ubuntu server and install/enable apache2
