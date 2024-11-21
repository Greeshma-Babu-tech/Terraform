terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

# Create a VPC
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc"
  }
}
# Create a Subnet
resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "my-subnet"
  }
}
# Create an Internet Gateway
resource "aws_internet_gateway" "myinternetgateway" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "my-IGW"
  }
}
# Create a Route Table
resource "aws_route_table" "myrtable" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "my-route-table"
  }
}
# Create a Route
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.myrtable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.myinternetgateway.id
}
# Subnet Asssociation
resource "aws_route_table_association" "subassociation" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.myrtable.id
}

# Create a Security Group
resource "aws_security_group" "allow_ssh" {
  vpc_id = aws_vpc.myvpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow-ssh"
  }
}

# Create a EC2 Instance with UserData
resource "aws_instance" "myInstance" {
  ami                    = "ami-00eb69d236edcfaf8"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.mysubnet.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Hello, World from $(hostname -f)" > /var/www/html/index.html
              EOF

  tags = {
    Name = "my-ec2-instance"
  }
}
