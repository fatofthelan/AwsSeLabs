/* This outputs the Public IP of the Public EC2 instance/Bastion Host */
output "Public IP Address of the Bastion Host" {
  value = "${aws_instance.bastion_host.public_ip}"
}

/* This outputs the Private IP of the Private EC2 instance */
output "Private IP Address of the Private Host" {
  value = "${aws_instance.private_host.private_ip}"
}
