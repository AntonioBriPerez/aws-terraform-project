provider "aws" {
  region = "us-east-1"
}


#A vpc is a virtual private cloud needed for ec2 resources
resource "aws_vpc" "prod-vpc" {

  cidr_block = "10.0.0.0/16" #network used for this vpc

  tags = {
    Name = "production"
  }
}

#An internet gateway is resource to enable access to and 
# from internet, is necessary to have an vpc. 
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id

}

#A route table contains a set of rules, called routes, 
#that are used to determine where network traffic from 
#your subnet or gateway is directed.
resource "aws_route_table" "prod-route-table" {
  vpc_id = "aws_vpc.prod-vpc.id"

  route {
    cidr_block = "0.0.0.0/0" #All IPv4 traffic is going to get sent wherever this route points. 
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "Prod"
  }
}

#now we create a subnet on which our server is going to be hosted
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.1.0/24" #must be in the range of the vpc 
  availability_zone = "us-east-1a"

  tags = {
    Name = "prod-subnet"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #any IP can access it
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #any IP can access it
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #any IP can access it
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1 #any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }


}

resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}


resource "aws_eip" "one" {
  /*
An Elastic IP address is a static public IPv4 address associated with your AWS 
account in a specific Region. Unlike an auto-assigned public IP address, an Elastic 
IP address is preserved after you stop and start your instance in a virtual private cloud (VPC).

For having a public IP address we first need and internet gateway
 deploying an elastic ip addres requires the internet gateway to be deployed first
*/

  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.0.50 "
  depends_on                = [aws_internet_gateway.gw] #we reference whole resource
}

resource "aws_instance" "web-server-instance" {
  ami               = "ami-052efd3df9dad4825" #us-east1
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "main-key"
  network_interface {
    device_index         = 0 #first network interface with this resource
    network_interface_id = aws_network_interface.web-server-nic.id
  }
  user_data = <<-EOF
                #!/bin/bash 
                sudo apt udpate -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo first web server :D > /var/www/html/index.html'
                EOF
  tags = {
    Name = "web-server"
  }
}
