# ---------------------------------------------------------
# ALB Security Group
# ---------------------------------------------------------

resource "aws_security_group" "alb" {
  name        = "${local.common_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.common_name}-alb-sg"
  }
}


# ---------------------------------------------------------
# Application Security Group
# ---------------------------------------------------------

resource "aws_security_group" "app" {
  name        = "${local.common_name}-app-sg"
  description = "Security group for application EC2 instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow application traffic from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.common_name}-app-sg"
  }
}


# ---------------------------------------------------------
# RDS Security Group
# ---------------------------------------------------------

resource "aws_security_group" "rds" {
  name        = "${local.common_name}-rds-sg"
  description = "Security group for PostgreSQL RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow PostgreSQL from application servers"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.common_name}-rds-sg"
  }
}