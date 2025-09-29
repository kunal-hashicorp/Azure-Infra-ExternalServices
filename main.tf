# ---------- Locals ----------
locals {
  # Route53 zone name handling
  zone_name = endswith(var.hosted_zone_name, ".") ? var.hosted_zone_name : "${var.hosted_zone_name}."

  # DNS record name: prefix + zone
  record_name = "${var.record_prefix}.${var.hosted_zone_name}"

  # Storage account name: prefix + env (must be lowercase, 3–24 chars, no dashes)
  storage_account_name = lower("${var.storage_account_prefix}${var.environment}")
}

# ---------- Resource Group ----------
resource "azurerm_resource_group" "rg" {
  name     = "${var.rg_prefix}-${var.environment}"
  location = var.location
  tags     = var.tags
}

# ---------- Networking ----------
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name_prefix}-vnet-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_cidr]
  tags                = var.tags
}

# Subnet for VM
resource "azurerm_subnet" "subnet" {
  name                 = "${var.name_prefix}-subnet-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidr]
}

# Subnet for PostgreSQL Flexible Server
resource "azurerm_subnet" "pg_subnet" {
  name                 = "${var.name_prefix}-pg-subnet-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.20.2.0/24"]

  delegation {
    name = "fsdelegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

# ---------- Network Security Group ----------
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name_prefix}-nsg-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Custom8800"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["8800"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# ---------- Public IP ----------
resource "azurerm_public_ip" "vm_pip" {
  name                = "${var.name_prefix}-pip-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# ---------- Network Interface ----------
resource "azurerm_network_interface" "nic" {
  name                = "${var.name_prefix}-nic-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip.id
  }
}

# ---------- Network Interface <-> NSG Association ----------
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id

  depends_on = [
    azurerm_network_interface.nic,
    azurerm_network_security_group.nsg
  ]
}

# ---------- Linux VM ----------
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.name_prefix}-vm-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = var.vm_size

  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.name_prefix}-osdisk-${var.environment}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  disable_password_authentication = true
  tags                             = var.tags

  depends_on = [
    azurerm_network_interface_security_group_association.nic_nsg
  ]
}

# ---------- Storage ----------
resource "azurerm_storage_account" "sa" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags

  blob_properties {
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "container" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "tfe_container" {
  name                  = "aks-tfe"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

# ---------- Private DNS Zone for PostgreSQL ----------
resource "azurerm_private_dns_zone" "pg_dns" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "pg_dns_link" {
  name                  = "${var.name_prefix}-dnslink-${var.environment}"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pg_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

# ---------- PostgreSQL Flexible Server ----------
resource "azurerm_postgresql_flexible_server" "pg" {
  name                   = "${var.name_prefix}-pg-${var.environment}"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = var.pg_version
  administrator_login    = var.pg_admin_username
  administrator_password = var.pg_admin_password

  sku_name            = "GP_Standard_D4s_v3"
  storage_mb          = 262144
  delegated_subnet_id = azurerm_subnet.pg_subnet.id
  private_dns_zone_id = azurerm_private_dns_zone.pg_dns.id

  public_network_access_enabled = false

  authentication {
    password_auth_enabled = true
  }

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "pgdb" {
  name      = var.pg_database_name
  server_id = azurerm_postgresql_flexible_server.pg.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

# ---------- AWS Route53 DNS ----------
data "aws_route53_zone" "target" {
  name         = local.zone_name
  private_zone = false
}

resource "aws_route53_record" "azure_vm_record" {
  zone_id = data.aws_route53_zone.target.zone_id
  name    = local.record_name
  type    = "A"
  ttl     = var.dns_record_ttl
  records = [azurerm_public_ip.vm_pip.ip_address]
}
