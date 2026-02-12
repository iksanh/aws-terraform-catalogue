variable "region" {
  description = "Aws Region untuk Deployment"
  type = string
  default = "us-east-1"

}

variable "project_name" {
    description = "Prefix nama project untuk taggaing resource"
    type = string
    default = "aurora-lab"
  
}

variable "vpc_cidr" {
    description = "CIDR block untuk VPC"
    type = string
    default = "10.0.0.0/16"
}

variable "db_username" {
    description = "username untuk database"
    type = string
    default = "admin"
}

variable "db_password" {
    description = "password untuk database (Sebagikan dinput via tvars atau environment variable)"
    sensitive = true
    type = string
  
}

variable "aurora_instance_class" {
    description = "Instance class untuk Aurora"
    type = string
    default = "db.t3.medium"
}

# variable "ec2_key_name" {
#     description = "Nama Key Pair EC2 yang existing"
#     type = string
  
# }

variable "allowed_cidr_ssh" {
  description = "IP ADDRESS yang dizinkan ssh ke Bastion Host"
  type = string
  default = "0.0.0.0/0"
}
