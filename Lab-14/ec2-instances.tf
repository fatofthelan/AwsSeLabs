/* This file creates two new EC2 instances. The Public instance is the bastion
host that you will connect to in order to connect to the Private instances. */

/* Creates the Public Instance/Bastion Host */
resource "aws_instance" "bastion_host" {
  ami                    = "${data.aws_ami.amazon-linux-2.id}"
  instance_type          = "${var.www_instance_type}"
  subnet_id              = "${aws_subnet.public_subnet.id}"
  key_name               = "${var.existing_ssh_keypair}"
  vpc_security_group_ids = ["${aws_security_group.SSH-to-Bastion-Host.id}"]

  tags {
    Name = "Lab14-Public"
  }
}

/* Creates a Private Instance with no Public IP address. */
resource "aws_instance" "private_host" {
  ami                    = "${data.aws_ami.amazon-linux-2.id}"
  instance_type          = "${var.www_instance_type}"
  subnet_id              = "${aws_subnet.private_subnet.id}"
  key_name               = "${var.existing_ssh_keypair}"
  vpc_security_group_ids = ["${aws_security_group.SSH-from-Bastion-Host.id}"]

  tags {
    Name = "Lab14-Private"
  }
}
