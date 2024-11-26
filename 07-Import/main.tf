
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
resource "aws_instance" "import-demo-instance" {
  # Configuration will be filled in after import

    ami                                  = "ami-0c80e2b6ccb9ad6d1"
    instance_type                        = "t2.micro"
    tags                                 = {
        "Name" = "import-demo-instance"
    }
    
}
