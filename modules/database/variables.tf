variable "db_password" {
  type      = string
  sensitive = true # Terraform will mask this in logs
}

variable "db_security_group_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  type        = string
}