terraform {
  backend "s3" {
    bucket         = "awsterraformconfig"
    key            = "statefile/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "awsterraformconfig-lock"
  }
}
