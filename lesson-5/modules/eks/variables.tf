variable "cluster_name" {
  description = "Name of the EKS cluster"
  default     = "example-eks-cluster"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for the worker nodes"
  default     = "t2.micro"
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  default     = 1
}

