/* Setting up the Provider to use AWS resources */
provider "aws" {
  region = "${var.aws_region}"
}

/* Create a custom VPC called Terraform-VPC with a private and public subnet */
resource "aws_vpc" "terraform_vpc" {
  cidr_block = "${var.vpc_cidr_block}"

  tags = {
    "Name" = "Terraform-VPC"
  }
}

/* Create the Internet Gateway and Elastic IP for the VPC/Public subnet */
resource "aws_eip" "internet_gw_eip" {
  vpc        = true
  depends_on = ["aws_vpc.terraform_vpc", "aws_internet_gateway.internet_gw"]

  tags {
    Name = "Terraform-VPC"
  }
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = "${aws_vpc.terraform_vpc.id}"

  tags {
    Name = "Terraform-VPC"
  }
}

/* Create the NAT Gateway and Elastic IP for the VPC/Private subnet */
resource "aws_eip" "nat_gw_eip" {
  vpc = true

  //depends_on = ["aws_vpc.terraform_vpc", "aws_nat_gateway.nat_gw"]

  tags {
    Name = "Terraform-VPC"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat_gw_eip.id}"
  subnet_id     = "${aws_subnet.public_subnet.id}"
}

/* Create the Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id            = "${aws_vpc.terraform_vpc.id}"
  cidr_block        = "${var.public_cidr_block}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags {
    "Name" = "Lab14Public"
  }
}

/* Create the Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id            = "${aws_vpc.terraform_vpc.id}"
  cidr_block        = "${var.private_cidr_block}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags {
    "Name" = "Lab14Private"
  }
}

/* Create the Route Tables and Associations for the VPC */
/* Create the Public Network Route Table */
resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.terraform_vpc.id}"

  tags {
    "Name" = "Terraform-VPC-Public"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

/* Create the Prive Network Route Table */
resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.terraform_vpc.id}"

  tags {
    "Name" = "Terraform-VPC-Private"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  subnet_id      = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

/* Create the routes for our Route Tables */
/* Define the Public routes */
resource "aws_route" "igw_route" {
  route_table_id         = "${aws_route_table.public_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.internet_gw.id}"
}

/* Define the Private routes */
resource "aws_route" "ngw_route" {
  route_table_id         = "${aws_route_table.private_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_nat_gateway.nat_gw.id}"
}

/* Access Control Section */
/* Define the Network ACL Profile */
resource "aws_network_acl" "terraform_vpc_nacl" {
  vpc_id = "${aws_vpc.terraform_vpc.id}"

  subnet_ids = [
    "${aws_subnet.public_subnet.id}",
    "${aws_subnet.private_subnet.id}",
  ]
}

resource "aws_network_acl_rule" "acl1" {
  network_acl_id = "${aws_network_acl.terraform_vpc_nacl.id}"
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "acl2" {
  network_acl_id = "${aws_network_acl.terraform_vpc_nacl.id}"
  rule_number    = 100
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

/* Define the Public Subnet Security Group */
resource "aws_security_group" "SSH-to-Bastion-Host" {
  name        = "SSH-to-Bastion-Host"
  description = "Allow admin access to Bastion Hosts"
  vpc_id      = "${aws_vpc.terraform_vpc.id}"

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] /* You should change this to your specific IP(s) */
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/* Define the Private Subnet Security Group */
resource "aws_security_group" "SSH-from-Bastion-Host" {
  name        = "SSH-from-Bastion-Host"
  description = "Allow admin access from Bastion Hosts"
  vpc_id      = "${aws_vpc.terraform_vpc.id}"

  ingress {
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.SSH-to-Bastion-Host.id}"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
