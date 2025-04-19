# Cluster parameter group (optional but recommended)
resource "aws_rds_cluster_parameter_group" "aurora_mysql_param_group" {
  name        = "${var.project_prefix}-aurora-mysql-params"
  family      = "aurora-mysql8.0" # Updated from 5.7 to 8.0
  description = "Aurora MySQL 8.0 parameter group"

  tags = {
    Name = "${var.project_prefix}-aurora-mysql-params"
  }
}


# Aurora DB Cluster
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "${var.project_prefix}-aurora-cluster"
  engine                  = "aurora-mysql"
  engine_mode             = "provisioned"
  master_username         = "jatharthan"
  master_password         = "jatharthan"
  backup_retention_period = 1
  preferred_backup_window = "07:00-09:00"
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.private_db_sg.id]
  storage_encrypted       = true
  availability_zones      = ["us-east-1a", "us-east-1b"]
  skip_final_snapshot     = true
  apply_immediately       = true
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_mysql_param_group.name

  lifecycle {
    ignore_changes = [availability_zones]
  }

  tags = {
    Name = "${var.project_prefix}-aurora-cluster"
  }
}

# Writer instance
resource "aws_rds_cluster_instance" "aurora_writer" {
  identifier              = "${var.project_prefix}-aurora-writer"
  cluster_identifier      = aws_rds_cluster.aurora_cluster.id
  instance_class          = "db.t3.medium"
  engine                  = "aurora-mysql"
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  availability_zone       = "us-east-1a"

  tags = {
    Name = "${var.project_prefix}-aurora-writer"
  }
}

# Reader instance
resource "aws_rds_cluster_instance" "aurora_reader" {
  identifier              = "${var.project_prefix}-aurora-reader"
  cluster_identifier      = aws_rds_cluster.aurora_cluster.id
  instance_class          = "db.t3.medium"
  engine                  = "aurora-mysql"
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  availability_zone       = "us-east-1b"

  tags = {
    Name = "${var.project_prefix}-aurora-reader"
  }
}

# Output the Writer Endpoint
output "aurora_writer_endpoint" {
  value = aws_rds_cluster.aurora_cluster.endpoint
  description = "Writer endpoint of the Aurora cluster"
}
