# Main Logic & Architecture
variable "use_aurora" {
  description = "If true, create an Aurora Cluster. If false, create a standard RDS instance."
  type        = bool
  default     = false
}

variable "aurora_replica_count" {
  description = "The number of read replicas to create for an Aurora cluster. Ignored if use_aurora is false."
  type        = number
  default     = 1
}

# General Database Settings
variable "db_name" {
  description = "The name for the database instance/cluster and the database itself."
  type        = string
}

variable "db_username" {
  description = "The username for the master user."
  type        = string
}

variable "db_password" {
  description = "The password for the master user."
  type        = string
  sensitive   = true
}

variable "engine" {
  description = "The database engine (e.g., 'postgres', 'aurora-postgresql')."
  type        = string
}

variable "engine_version" {
  description = "The database engine version."
  type        = string
}

variable "instance_class" {
  description = "The instance class for the DB (e.g., 'db.t3.medium')."
  type        = string
}

# Network & Security
variable "vpc_id" {
  description = "ID of the VPC where the DB will be deployed."
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs."
  type        = list(string)
  default     = []
}

variable "publicly_accessible" {
  description = "Determines if the database is publicly accessible. Selects public or private subnets."
  type        = bool
  default     = false
}

variable "allowed_cidr_blocks" {
  description = "A list of CIDR blocks allowed to connect to the database."
  type        = list(string)
  default     = ["0.0.0.0/0"] # Restrict in prod
}

# Storage, Backups & Availability
variable "allocated_storage" {
  description = "Storage for standard RDS (in GB). Ignored for Aurora."
  type        = number
  default     = 20
}

variable "multi_az" {
  description = "Enable Multi-AZ for standard RDS. Ignored for Aurora (which is multi-AZ by design)."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "If true, a final snapshot will not be taken on deletion. Set to false for production."
  type        = bool
  default     = true
}

# Configuration Parameters
variable "parameter_group_params" {
  description = "A list of parameters to apply to the DB."
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
}

# Tagging
variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}