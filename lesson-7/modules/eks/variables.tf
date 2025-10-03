variable "cluster_name" {
  type = string
}
variable "cluster_version" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "private_subnets" {
  type = list(string)
}
# Add this new variable
variable "public_subnets" {
  type = list(string)
}