# ---------------------------------------------------------
# RDS Subnet Group
# ---------------------------------------------------------

resource "aws_db_subnet_group" "postgres" {
  name = "${local.common_name}-db-subnet-group"

  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${local.common_name}-db-subnet-group"
  }
}


# ---------------------------------------------------------
# PostgreSQL RDS
# ---------------------------------------------------------

resource "aws_db_instance" "postgres" {
  identifier = "${local.common_name}-postgres"

  engine         = "postgres"
  engine_version = "16"

  instance_class = var.db_instance_class

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.postgres.name

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  publicly_accessible = false

  backup_retention_period = 7

  skip_final_snapshot = true

  tags = {
    Name = "${local.common_name}-postgres"
  }
}