output "public_ip" {
  description = "Public IP of the Azure VM"
  value       = azurerm_public_ip.vm_pip.ip_address
}

output "private_ip" {
  description = "Private IP of the Azure VM"
  value       = azurerm_network_interface.nic.ip_configuration[0].private_ip_address
}

output "postgresql_hostname" {
  description = "FQDN of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.pg.fqdn
}

output "resource_group" {
  description = "Resource Group Name"
  value       = azurerm_resource_group.rg.name
}

output "azure_dns_record" {
  description = "FQDN of the Azure VM in AWS Route53"
  value       = aws_route53_record.azure_vm_record.fqdn
}

# ---------- TFE related outputs ----------
output "tfe_object_storage_type" {
  description = "Object storage type for TFE"
  value       = "azure"
}

output "tfe_object_storage_account_name" {
  description = "Azure Storage Account used for TFE"
  value       = azurerm_storage_account.sa.name
}

output "tfe_object_storage_container" {
  description = "Azure Storage Container used for TFE"
  value       = azurerm_storage_container.tfe_container.name
}
