variable "region" {
  default = "us-east-1"
}

variable "application_name" {
  type    = string
  default = "aws-censo-ed-superior"
}

# ------------------------------------------------------------
# Airflow Settings
# ------------------------------------------------------------
variable "airflow_admin_user" {
  type        = string
  description = "Admin user of the Airflow"
  default     = "admin"
}

variable "airflow_admin_password" {
  type        = string
  description = "Admin password of the Airflow"
  default     = "admin"
}