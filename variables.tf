variable "environment" { type = string }
variable "rg_prefix" { type = string }
variable "location" { type = string }
variable "name_prefix" { type = string }

variable "vnet_cidr" { type = string }
variable "subnet_cidr" { type = string }

# VM
variable "vm_size" { type = string }
variable "admin_username" { type = string }
variable "ssh_public_key_path" { type = string }
variable "os_disk_size_gb" { type = number }

# Storage
variable "storage_account_prefix" { type = string }
variable "storage_container_name" { type = string }

# AWS Route53
variable "aws_region" { type = string }
variable "hosted_zone_name" { type = string }
variable "record_prefix" { type = string }
variable "dns_record_ttl" { type = number }

# Tags
variable "tags" { type = map(string) }

# PostgreSQL
variable "pg_admin_username" { type = string }
variable "pg_admin_password" { type = string }
variable "pg_database_name" { type = string }
variable "pg_version" {
  description = "PostgreSQL Flexible Server version"
  type        = string
  default     = "15"
}
