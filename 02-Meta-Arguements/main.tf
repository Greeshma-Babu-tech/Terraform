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
#for_each parameter is used to create multiple instances of a resource based on a collection (list or map).
resource "aws_instance" "webserver" {
  for_each = {
    windows = "ami-0642ac1cc7ac6f4bf"
    ubuntu  = "ami-0ea3c35c5c3284d82"
  }
  ami           = each.value
  instance_type = "t3.micro"
  tags = {
    Name = each.key
  }
}
#count arameter is used to create multiple instances of a resource based on a specified number.
resource "aws_instance" "webserver" {
  count         = 3
  ami           = "ami-00eb69d236edcfaf8"
  instance_type = "t2.micro"
  tags = {
    Name = "server-${count.index}"
    //count.index start with 0 i.e,server-0,server-1...
  }
}

//Input variables in Terraform let you parameterize configurations, making them flexible and reusable.
variable "bucket_names" {
  default = ["gb-bucket-blue", "gb-bucket-red", "gb-bucket-green"]
}
resource "aws_s3_bucket" "gb_buckets" {
  for_each = toset(var.bucket_names)
  //The toset function in Terraform is used to convert a list or other collection into a set.
  bucket   = each.key
  //To prevent resource deletion during a terraform destroy operation, you can use the prevent_destroy
  lifecycle {
    prevent_destroy = false
  }

}

