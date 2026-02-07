output "ec2_client_public_ip" {
  description = "Public IP of the EC2 Client to SSH into"
  value       = aws_instance.web_client.public_ip
}

output "ec2_ssh_command" {
  description = "Command to SSH into EC2"
  value       = "ssh -i /path/to/${var.ssh_key_name}.pem ec2-user@${aws_instance.web_client.public_ip}"
}

output "rds_endpoint_single_az" {
  description = "Connection endpoint for Single-AZ RDS"
  value       = aws_db_instance.single_az.address
}

output "rds_endpoint_multi_az" {
  description = "Connection endpoint for Multi-AZ RDS"
  value       = aws_db_instance.multi_az.address
}