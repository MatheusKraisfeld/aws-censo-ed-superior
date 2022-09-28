variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "account" {
  default = "741358071637"
}

variable "project_name" {
  default = "aws-censo-ed-superior"
}

variable "zone_bucket_names" {
  description = "Create S3 buckets with these names"
  type        = list(string)
  default = [
    "censo-ed-superior-landing",
    "censo-ed-superior-bronze",
    "censo-ed-superior-silver",
    "censo-ed-superior-gold",
    "censo-ed-superior-logs"
  ]
}

variable "bucket_scripts" {
  description = "Scripts to be executed in the crawler"
  default     = "censo-ed-superior-resources"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "censo-ed-superior-eks"
}

variable "db_password" {
  description = "RDS root user password"
  sensitive   = true
  default     = "" # This is a bad practice. You should use a password manager to generate a random password.
}