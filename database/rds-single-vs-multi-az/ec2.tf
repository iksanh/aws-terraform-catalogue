resource "aws_instance" "web_client" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.public[0].id # Place in 1st Public Subnet
  #key_name      = var.ssh_key_name
  
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # Script untuk install tools saat booting
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              # Install MariaDB package which includes the 'mysql' command client
              yum install -y mariadb
              # Install Telnet & Git (optional utils)
              yum install -y telnet git
              EOF

  tags = {
    Name = "${var.project_name}-client"
  }
}