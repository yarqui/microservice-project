variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint for the EKS cluster."
  type        = string
}

variable "cluster_ca_certificate" {
  description = "The CA certificate for the EKS cluster."
  type        = string
}
