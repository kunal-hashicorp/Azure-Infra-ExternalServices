rg_name     = "rg-azure-tfdemo"
location    = "Central India"
name_prefix = "tfdemo"

vnet_cidr   = "10.20.0.0/16"
subnet_cidr = "10.20.1.0/24"

vm_size             = "Standard_B2s"
admin_username      = "ubuntu"
ssh_public_key_path = "./jenkins_gcp_key.pub"
os_disk_size_gb     = 64

storage_account_name   = "kstfdemoacct9876"
storage_container_name = "artifacts"

dns_zone_name   = "example.com"
dns_record_name = "app"
dns_record_ttl  = 300

tags = {
  project     = "azure-tf"
  environment = "dev"
  owner       = "kunal"
}

pg_admin_username = "postgres"
pg_admin_password = "Iamdb123"
pg_database_name  = "kunals"
