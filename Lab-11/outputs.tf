/* This outputs the IP of the EC2 instance */
output "EC2_Host_IP_Address-URL" {
  value = join("", ["http://", aws_instance.www.public_ip])
}

