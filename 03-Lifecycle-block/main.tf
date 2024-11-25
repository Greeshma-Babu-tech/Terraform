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
