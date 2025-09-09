output "public_ip" {
  value = azurerm_public_ip.vm_pip.ip_address
}

output "private_ip" {
  value = azurerm_network_interface.nic.ip_configuration[0].private_ip_address
}

output "postgresql_hostname" {
  value = azurerm_postgresql_flexible_server.pg.fqdn
}

output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "storage_account_region" {
  value = azurerm_storage_account.sa.location
}
