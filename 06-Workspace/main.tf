variable "ami_id" {}
variable "instance_type" {}
variable "Name" {
  description = "Name of the instance"
  type        = string
}
variable "env" {}

provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "myinstance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = var.Name
    Env  = var.env
  }
}
