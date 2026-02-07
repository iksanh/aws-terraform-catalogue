# Subnet Group (menggabungkan 2 private subnet)
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "My DB Subnet Group"
  }
}

# DB #1: Single-AZ
resource "aws_db_instance" "single_az" {
  identifier           = "rds-single-az"
  allocated_storage    = 20
  storage_type         = "gp3"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  
  # Networking
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  
  # Settings Utama
  multi_az            = false
  publicly_accessible = false
  skip_final_snapshot = true # Agar mudah di destroy saat riset selesai
  
  # Backup
  backup_retention_period = 7
  backup_window           = "03:00-04:00"

  tags = { Name = "RDS-Single-AZ" }
}

# DB #2: Multi-AZ
resource "aws_db_instance" "multi_az" {
  identifier           = "rds-multi-az"
  allocated_storage    = 20
  storage_type         = "gp3"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  
  # Networking
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  
  # Settings Utama
  multi_az            = true  # ENABLED
  publicly_accessible = false
  skip_final_snapshot = true
  
  # Backup
  backup_retention_period = 7
  backup_window           = "03:00-04:00"

  tags = { Name = "RDS-Multi-AZ" }
}