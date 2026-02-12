provider "aws" {
  region = var.region
}

# Data Source untuk mengambil AZs yang tersedia di region yang dipilih
data "aws_availability_zones" "available" {
  state = "available"
}

# Data Source untuk AMI Linux terbaru
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# --- 1. VPC & Networking ---
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  # Mengambil 3 AZ pertama secara otomatis
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  map_public_ip_on_launch = true

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Environment = "Lab"
    Project     = var.project_name
  }
}


# --- NEW: Generate SSH Key Pair Otomatis ---

# 1. Membuat Private Key RSA 4096-bit di memori
resource "tls_private_key" "lab_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. Menyimpan Private Key ke file lokal (laptop)
resource "local_file" "lab_key_file" {
  content  = tls_private_key.lab_key.private_key_pem
  filename = "${path.module}/${var.project_name}-key.pem"
  
  # Set permission file agar aman (setara chmod 400 di Linux/Mac)
  file_permission = "0400" 
}

# 3. Mendaftarkan Public Key ke AWS
resource "aws_key_pair" "lab_key_pair" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.lab_key.public_key_openssh
}

# --- 2. Security Groups ---

resource "aws_security_group" "bastion_sg" {
  name        = "${var.project_name}-bastion-sg"
  description = "Allow SSH inbound"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr_ssh]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "aurora_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Allow MySQL from Bastion"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- 3. Aurora Cluster ---
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "${var.project_name}-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "${var.project_name}-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.04.0"
  availability_zones      = slice(data.aws_availability_zones.available.names, 0, 3)
  database_name           = "labdb"
  master_username         = var.db_username
  master_password         = var.db_password
  backup_retention_period = 1
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.aurora_sg.id]
  
  tags = {
    Name = "${var.project_name}-cluster"
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 1
  identifier         = "${var.project_name}-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = var.aurora_instance_class
  engine             = aws_rds_cluster.aurora_cluster.engine
  engine_version     = aws_rds_cluster.aurora_cluster.engine_version
}

# --- 4. EC2 Bastion Host ---
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  subnet_id     = module.vpc.public_subnets[0]
  
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  # UPDATE : Gunakan key pair yang dibuat terraform
  key_name               = aws_key_pair.lab_key_pair.key_name
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y mysql
              EOF

  tags = {
    Name = "${var.project_name}-bastion"
  }
}