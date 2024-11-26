terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.77.0"
    }
  }
  backend "s3" {
    bucket         = "awsterraformconfig"
    region         = "us-east-2"
    key            = "statefile/terraform.tfstate"
    dynamodb_table = "awsterraformconfig-lock"
  }
}

provider "aws" {
  # Configuration options
}