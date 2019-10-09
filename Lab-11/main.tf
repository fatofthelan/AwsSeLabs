/* Setting up the Provider to use AWS resources */
provider "aws" {
  region = var.aws_region
}

/* AWS Instance to be created. */
resource "aws_instance" "www" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = var.www_instance_type
  key_name               = var.existing_ssh_keypair
  vpc_security_group_ids = [aws_security_group.www_server.id]

  tags = {
    Name = "Lab11"
  }

  /* Copy the local template.html file to /var/www/html/index.html */
  user_data = <<EOF
  #!/bin/bash
  yum update -y
  yum install -y httpd
  service httpd start
  ckconfig httpd on
  echo "${data.template_file.user_data.rendered}" > /var/www/html/index.html
EOF

}

/* Essentially creates a variable that contains the template.html page for use in user_data */
data "template_file" "user_data" {
  template = file("template.html")
}

/* Security group to allow all traffic */
resource "aws_security_group" "www_server" {
  name        = "Allow-http-ssh"
  description = "Allows http and ssh traffic"
}

resource "aws_security_group_rule" "allow_http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.www_server.id
}

resource "aws_security_group_rule" "allow_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.www_server.id
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.www_server.id
}

