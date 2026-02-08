variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix for resource naming"
  type        = string
  default     = "rds-research"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ec2_instance_type" {
  description = "Instance type for EC2 Client"
  type        = string
  default     = "t3.micro"
}

#variable "ssh_key_name" {
#  description = "Name of existing SSH Key Pair in AWS for EC2 access"
#  type        = string
#}

variable "db_username" {
  description = "Master username for RDS"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master password for RDS (sensitive)"
  type        = string
  sensitive   = true
}