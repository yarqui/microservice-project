output "db_endpoint" {
  description = "The connection endpoint for the database writer instance."
  value       = try(aws_db_instance.rds[0].endpoint, aws_rds_cluster.aurora[0].endpoint)
}

output "db_reader_endpoints" {
  description = "A list of connection endpoints for the read replicas."
  value       = var.use_aurora ? aws_rds_cluster_instance.aurora_readers[*].endpoint : []
}

output "db_port" {
  description = "The port for the database."
  value       = try(aws_db_instance.rds[0].port, aws_rds_cluster.aurora[0].port)
}

output "db_name" {
  description = "The name of the database."
  value       = var.db_name
}

output "security_group_id" {
  description = "The ID of the security group created for the database."
  value       = aws_security_group.rds_sg.id
}