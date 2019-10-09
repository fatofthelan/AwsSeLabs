variable "vpc_cidr_block" {
  default = "10.20.0.0/16"
}

variable "public_cidr_block" {
  default = "10.20.0.0/24"
}

variable "private_cidr_block" {
  default = "10.20.1.0/24"
}

variable "www_instance_type" {
  default = "t2.micro"
}

variable "existing_ssh_keypair" {
  default = "OregonKeyPair"
}

variable "aws_region" {
  default = "us-west-2"
}

/* Create a list of Host AMI's for Amazon Linux 2 */
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

/* Fetch a list of availability zones and create a RO variable */
data "aws_availability_zones" "available" {
}

