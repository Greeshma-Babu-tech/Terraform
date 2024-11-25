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
#Create VPC
resource "aws_vpc" "demovpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}
#Create Subnet
resource "aws_subnet" "publicsubnet" {
  vpc_id                  = aws_vpc.demovpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "my-subnet"
  }
}
#Create Internet Gateway
resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.demovpc.id
  tags = {
    Name = "my-internet-gateway"
  }
}

#Create Route table
resource "aws_route_table" "routetable" {
  vpc_id = aws_vpc.demovpc.id
  tags = {
    Name = "my-route-table"
  }
}
#Add Routes in Route table
resource "aws_route" "defaultroute" {
  route_table_id         = aws_route_table.routetable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

}
#Create Route Table Association
resource "aws_route_table_association" "association" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.routetable.id
}
#Create Security Group
resource "aws_security_group" "allow_http_ssh" {
  vpc_id = aws_vpc.demovpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-http-ssh"
  }
}
# Generate Key pair
resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = file(var.public_key_path)
}

# Create Ec2 Instance
resource "aws_instance" "webserver" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.publicsubnet.id
  key_name = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_http_ssh.id]
  
  // Writes the instance's public IP to a file.
  provisioner "local-exec" {
    command = "echo ${aws_instance.webserver.public_ip} > ip_address.txt"
  }
  tags = {
    Name = "Provisioners-demo"
  }
}

resource "null_resource" "example" {
  //Copies the install_apache.sh script to the instance.
  provisioner "file" {
    source      = "install_apache.sh"
    destination = "/tmp/install_apache.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = aws_instance.webserver.public_ip
    }
  }
  //Executes the install_apache.sh script on the instance.
  provisioner "remote-exec" {
    inline = ["chmod +x /tmp/install_apache.sh", "sudo /tmp/install_apache.sh"]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = aws_instance.webserver.public_ip
    }
  }
  depends_on = [aws_instance.webserver]
}

output "instance_ip" {
  value = aws_instance.webserver.public_ip

}
