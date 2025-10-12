# The main Aurora Cluster resource
resource "aws_rds_cluster" "aurora" {
  count = var.use_aurora ? 1 : 0
  
  cluster_identifier              = var.db_name
  engine                          = var.engine
  engine_version                  = var.engine_version
  database_name                   = var.db_name
  
  master_username                 = var.db_username
  master_password                 = var.db_password
  
  db_subnet_group_name            = aws_db_subnet_group.main.name
  vpc_security_group_ids          = [aws_security_group.rds_sg.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_params[0].name

  skip_final_snapshot             = var.skip_final_snapshot
  final_snapshot_identifier       = var.skip_final_snapshot ? null : "${var.db_name}-final-snapshot"

  tags = local.common_tags
}

# The primary WRITER instance for the cluster
resource "aws_rds_cluster_instance" "aurora_writer" {
  count = var.use_aurora ? 1 : 0

  identifier            = "${var.db_name}-writer"
  cluster_identifier    = aws_rds_cluster.aurora[0].id
  instance_class        = var.instance_class
  engine                = var.engine
  publicly_accessible   = var.publicly_accessible
  
  tags = local.common_tags
}

# The READER replicas for the cluster
resource "aws_rds_cluster_instance" "aurora_readers" {
  count = var.use_aurora ? var.aurora_replica_count : 0

  identifier            = "${var.db_name}-reader-${count.index}"
  cluster_identifier    = aws_rds_cluster.aurora[0].id
  instance_class        = var.instance_class
  engine                = var.engine
  publicly_accessible   = var.publicly_accessible
  
  tags = local.common_tags
}