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

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}
