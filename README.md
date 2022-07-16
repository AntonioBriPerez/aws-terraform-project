# aws-terraform-project

## Steps

### 1. Create VPC
### 2. Create Internet Gateway
### 3. Create custom route table
### 4. Create a subnet.
A subnet is a range of IP addresses in your VPC. You can attach AWS resources, such as EC2 instances and RDS DB instances, to subnets. You can create subnets to group instances together according to your security and operational needs.
### 1. Associate subnet with Route Table
### 2. Create Security Group to allow port 22, 80, 443
### 3. Create a network interface with an ip in the subnet that was created in step 4
### 4. Assign an elastic IP to the network interface created in step 7
### 5. Create Ubuntu server and install/enable apache2
