/* This outputs the Public IP of the Public EC2 instance/Bastion Host */
output "Public_IP_Address_of_the_Bastion_Host" {
  value = aws_instance.bastion_host.public_ip
}

/* This outputs the Private IP of the Private EC2 instance */
output "Private_IP_Address_of_the_Private_Host" {
  value = aws_instance.private_host.private_ip
}

