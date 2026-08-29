# ---------------------------------------------------------
# Ubuntu AMI
# ---------------------------------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# ---------------------------------------------------------
# Application EC2 Instances
# ---------------------------------------------------------

resource "aws_instance" "app" {
  count = 2

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.private[count.index].id

  vpc_security_group_ids = [
    aws_security_group.app.id
  ]

  user_data = <<-EOF
              #!/bin/bash

              apt-get update -y
              apt-get install -y nginx

              systemctl enable nginx
              systemctl start nginx

              echo "Hello from $(hostname)" > /var/www/html/index.html
              EOF

  tags = {
    Name = "${local.common_name}-app-${count.index + 1}"
  }
}