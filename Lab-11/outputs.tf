/* This outputs the IP of the EC2 instance */
output "EC2 Host IP Address" {
  value = "${join("", list("http://", "${aws_instance.www.public_ip}"))}"
}