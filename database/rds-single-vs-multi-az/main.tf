# Mengambil daftar AZ yang tersedia di region tersebut
data "aws_availability_zones" "available" {
  state = "available"
}

# Mengambil AMI Amazon Linux 2 terbaru
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}