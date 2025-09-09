variable "rg_name" { type = string }
variable "location" { type = string }
variable "name_prefix" { type = string }

variable "vnet_cidr" { type = string }
variable "subnet_cidr" { type = string }

variable "vm_size" { type = string }
variable "admin_username" { type = string }
variable "ssh_public_key_path" { type = string }
variable "os_disk_size_gb" { type = number }

variable "storage_account_name" { type = string }
variable "storage_container_name" { type = string }

variable "dns_zone_name" { type = string }
variable "dns_record_name" { type = string }
variable "dns_record_ttl" { type = number }

variable "tags" {
  type = map(string)
}

# PostgreSQL vars
variable "pg_admin_username" { type = string }
variable "pg_admin_password" { type = string }
variable "pg_database_name"  { type = string }
