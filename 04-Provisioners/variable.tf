variable "instance_ami" {
  description = "AMI ID for the instance"
  default     = "ami-0ea3c35c5c3284d82"
}

variable "instance_type" {
  description = "Type of instance to create"
  default     = "t2.micro"
}
variable "public_key_path" {
  description = "Path to the SSH public key"
  default     = "C:/Users/Dell/.ssh/my-key.pub"
}

variable "private_key_path" {
  description = "Path to the SSH private key"
  default     = "C:/Users/Dell/.ssh/my-key"
}
