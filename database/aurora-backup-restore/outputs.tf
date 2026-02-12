output "aurora_endpoint" {
  description = "Endpoint Writer untuk Aurora Cluster"
  value       = aws_rds_cluster.aurora_cluster.endpoint
}

output "aurora_read_endpoint" {
  description = "Endpoint Reader untuk Aurora Cluster (jika ada replica)"
  value       = aws_rds_cluster.aurora_cluster.reader_endpoint
}

output "bastion_public_ip" {
  description = "Public IP dari Bastion Host"
  value       = aws_instance.bastion.public_ip
}



output "connection_command" {
  description = "Copy paste command ini di terminal untuk masuk ke Bastion"
  value       = "ssh -i ${local_file.lab_key_file.filename} ec2-user@${aws_instance.bastion.public_ip}"
}