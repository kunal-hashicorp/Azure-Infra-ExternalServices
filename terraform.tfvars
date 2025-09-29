environment = "dev"

rg_prefix   = "rg-azure"
name_prefix = "tfdemo"
location    = "Central India"

vnet_cidr   = "10.20.0.0/16"
subnet_cidr = "10.20.1.0/24"

vm_size             = "Standard_B2s"
admin_username      = "ubuntu"
ssh_public_key_path = "./jenkins_gcp_key.pub"
os_disk_size_gb     = 64

storage_account_prefix = "kstfdemoacct"
storage_container_name = "artifacts"

# AWS DNS
aws_region       = "ap-south-1"
hosted_zone_name = "tf-support.hashicorpdemo.com"
record_prefix    = "ksazure-repmd4"
dns_record_ttl   = 300

tags = {
  project     = "azure-tf"
  environment = "dev"
  owner       = "kunal"
}

pg_admin_username = "postgres"
pg_admin_password = "Iamdb123"
pg_database_name  = "kunals"
pg_version        = "15"

