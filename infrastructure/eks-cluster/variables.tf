variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "censo-ed-superior-eks"
}

variable "db_password" {
  description = "RDS root user password"
  sensitive   = true
  default     = "Administrator" # This is a bad practice. You should use a password manager to generate a random password.
}