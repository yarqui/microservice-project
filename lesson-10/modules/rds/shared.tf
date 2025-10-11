locals {
  parameter_group_family = "${var.engine}${element(split(".", var.engine_version), 0)}"

  common_tags = merge(
    {
      "TerraformModule" = "RDS"
      "Engine"          = var.engine
    },
    var.tags
  )
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.db_name}-sng"
  subnet_ids = var.publicly_accessible ? var.public_subnet_ids : var.private_subnet_ids

  tags = local.common_tags
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.db_name}-sg"
  description = "Allow traffic to RDS/Aurora instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow DB traffic from specified CIDRs"
    from_port   = 5432 # Assuming PostgreSQL.
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_db_parameter_group" "rds_params" {
  count  = var.use_aurora ? 0 : 1
  name   = "${var.db_name}-rds-pg"
  family = local.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameter_group_params
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }
  tags = local.common_tags
}

resource "aws_rds_cluster_parameter_group" "aurora_params" {
  count  = var.use_aurora ? 1 : 0
  name   = "${var.db_name}-aurora-cpg"
  family = local.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameter_group_params
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }
  tags = local.common_tags
}